package org.sustain.mongodb;

import com.mongodb.MongoClientSettings;
import com.mongodb.ServerAddress;
import com.mongodb.client.*;

import com.mongodb.client.model.*;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class MongoQuery {

    public static Logger log = LoggerFactory.getLogger(MongoQuery.class);

    public static final String MONGO_HOST = "lattice-100";
    public static final Integer MONGO_PORT = 27018;

    public MongoClient mongoClient;
    public MongoCollection<Document> collection;
    public String databaseName, collectionName;

    public MongoQuery(String databaseName, String collectionName) {
        this.databaseName = databaseName;
        this.collectionName = collectionName;
        this.mongoClient = MongoClients.create(
                MongoClientSettings.builder()
                        .applyToClusterSettings(builder ->
                                builder.hosts(
                                        List.of(
                                                new ServerAddress(MONGO_HOST, MONGO_PORT)
                                        )
                                )
                        )
                        .build()
        );

        MongoDatabase database = this.mongoClient.getDatabase(databaseName);
        this.collection = database.getCollection(collectionName);
    }

    /**
     * Retrieves the oldest date in the collection, and the most recent date in the collection.
     * The date is represented as an ISODate object in MongoDB, i.e. "DATE": ISODate("2017-09-01T00:00:00Z")
     * @return min and max dates as a List of Java Date objects
     */
    public List<Date> getMinAndMaxDates(String gisJoin) {

        //log.info("Using precomputed min date of 202001010000 and max date of 202110010000");
        //return new ArrayList<>(List.of(202101010000L, 202106010000L));

        log.info("Getting min and max dates for {}.{}", this.databaseName, this.collectionName);
        AggregateIterable<Document> results = this.collection.aggregate(
                List.of(
                        Aggregates.match(Filters.eq("GISJOIN", gisJoin)),
                        Aggregates.group(
                                null,
                                Accumulators.min("MIN_DATE", "$DATE"),
                                Accumulators.max("MAX_DATE", "$DATE")
                        )
                )
        );

        Document first = results.first();

        if (first != null) {
            Date min = first.getDate("MIN_DATE");
            Date max = first.getDate("MAX_DATE");
            if (min != null && max != null) {
                log.info("Successfully found min date {} and max date {}", min, max);
                return new ArrayList<>() {
                    {
                        add(min);
                        add(max);
                    }
                };
            }
        }
        log.error("Unable to find min and max dates!");
        return null;
    }

    public List<Double> findBlockExtrema(String field, String gisJoin, Integer timestep, List<Date> periodBoundaries) {
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
        StringBuilder sb = new StringBuilder("Executing MongoDB query to find block extrema:");
        sb.append(String.format("\tField: %s,\n",field));
        sb.append("\tBuckets: [\n");
        for (Date periodBoundary: periodBoundaries) {
            sb.append(String.format("\t\t%s\n", format.format(periodBoundary)));
        }
        sb.append("\t]");
        log.info(sb.toString());

        FindIterable<Document> testResults = this.collection.find(
                Filters.eq("GISJOIN", gisJoin)
        ).limit(1);

        for (Document document: testResults) {
            log.info(document.toJson());
        }

        List<Double> blockExtrema = new ArrayList<>();

        Date defaultBucketDate = periodBoundaries.get(periodBoundaries.size()-1);
        Bson matchStage = Aggregates.match(Filters.and(
                Filters.eq("GISJOIN", gisJoin)
        ));
        Bson bucketStage = Aggregates.bucket(
                "$DATE",
                periodBoundaries,
                new BucketOptions()
                        .defaultBucket(defaultBucketDate)
                        .output(
                                Accumulators.max("MAX_"+field, "$"+field)
                        )
        );

        log.info("Match stage: {}", matchStage.toBsonDocument().toJson());
        log.info("Bucket stage: {}", bucketStage.toBsonDocument().toJson());

        AggregateIterable<Document> results = this.collection.aggregate(
                Arrays.asList(
                        matchStage,
                        bucketStage
                )
        );

        for (Document result: results) {
            log.info(result.toJson());
            blockExtrema.add(result.getDouble("MAX_"+field));
        }

        return blockExtrema;
    }
}
