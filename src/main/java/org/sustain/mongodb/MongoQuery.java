package org.sustain.mongodb;

import com.mongodb.MongoClientSettings;
import com.mongodb.ServerAddress;
import com.mongodb.client.*;

import com.mongodb.client.model.*;
import org.bson.Document;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
     * The date is represented as an integer YYYYMMDDHH, i.e.:
     * 2010020400 would be year 2010, month 02 (February), day 04, and hour 00.
     * @return min and max dates
     */
    public List<Long> getMinAndMaxDates(String gisJoin) {
        log.info("Getting min and max dates for {}.{}", this.databaseName, this.collectionName);
        AggregateIterable<Document> results = this.collection.aggregate(
                List.of(
                        Aggregates.match(Filters.eq("GISJOIN", gisJoin)),
                        Aggregates.group(
                                null,
                                Accumulators.max("max", "$YYYYMMDDHH"),
                                Accumulators.min("min", "$YYYYMMDDHH")
                        )
                )
        );

        Document first = results.first();
        if (first != null) {
            Long min = first.getLong("min");
            Long max = first.getLong("max");
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

    public List<Double> findBlockExtrema(String field, String gisJoin, Integer timestep, List<Long> periodBoundaries) {
        log.info("Executing MongoDB query to find block extrema");
        AggregateIterable<Document> results = collection.aggregate(
                Arrays.asList(
                        Aggregates.match(Filters.and(
                                Filters.eq("GISJOIN", gisJoin),
                                Filters.eq("TIMESTEP", timestep)
                        )),
                        Aggregates.bucket(
                                "$YYYYMMDDHH",
                                periodBoundaries,
                                new BucketOptions()
                                        .output(
                                                Accumulators.max("max_"+field, "$"+field)
                                        )
                        )

                )
        );

        List<Double> blockExtrema = new ArrayList<>();
        for (Document result: results) {
            blockExtrema.add(result.getDouble("max_"+field));
        }

        return blockExtrema;
    }
}
