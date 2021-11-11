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
    public List<Integer> getMinAndMaxDates() {
        log.info("Getting min and max dates for {}.{}", this.databaseName, this.collectionName);
        AggregateIterable<Document> results = this.collection.aggregate(
                List.of(
                        Aggregates.match(Filters.eq("GISJOIN", "G1200870")),
                        Aggregates.group(
                                null,
                                Accumulators.max("max", "$YYYYMMDDHH")
                        )
                )
        );

        log.info("RESULTS: {}", results);
        for (Document result:  results) {
            log.info(result.toJson());
        }

//        Document first = results.first();
//        if (first != null) {
//            Integer min = first.getInteger("min_date");
//            Integer max = first.getInteger("max_date");
//            if (min != null && max != null) {
//                log.info("Successfully found min date {} and max date {}", min, max);
//                return new ArrayList<>() {
//                    {
//                        add(min);
//                        add(max);
//                    }
//                };
//            }
//        }
//        log.error("Unable to find min and max dates!");
//        return null;
        return null;
    }

    /*
        use sustaindb;
        db.noaa_nam.aggregate([
          {
            "$match": { "gis_join": "G4100470", "timestep": 0 }
          },
          {
            "$bucket": {
              "groupBy": "$year_month_day_hour",
              "boundaries": [
                2010010100,
                2010010700,
                2010011400,
                2010012100,
                2010012800,
                2010020400,
                2010021100,
                2010021800,
                2010022500
              ],
              "default": 2010030100,
              "output": {
                "max_precip_kg_sq_meter": { "$max": "$precipitable_water_kg_per_squared_meter" }
              }
            }
          },
          {
            "$sort": { "_id": 1 }
          }
        ])
     */

    public List<Double> findBlockExtrema(String field, String gisJoin, Integer timestep, List<Integer> periodBoundaries) {
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
                                                Accumulators.max("$max_"+field, "$"+field)
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
