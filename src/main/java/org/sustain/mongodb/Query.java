package org.sustain.mongodb;

import com.mongodb.MongoClientSettings;
import com.mongodb.ServerAddress;
import com.mongodb.client.*;

import com.mongodb.client.model.*;
import org.bson.Document;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sustain.matlab.eva.EvaController;

import java.util.Arrays;
import java.util.List;

public class Query {

    public static Logger log = LoggerFactory.getLogger(Query.class);

    public static final String MONGO_HOST = "lattice-100";
    public static final Integer MONGO_PORT = 27018;

    public MongoClient mongoClient;
    public MongoCollection<Document> collection;
    public String databaseName, collectionName;

    public Query(String databaseName, String collectionName) {
        this.databaseName = databaseName;
        this.collectionName = collectionName;
        this.mongoClient = MongoClients.create(
                MongoClientSettings.builder()
                        .applyToClusterSettings(builder ->
                                builder.hosts(List.of(new ServerAddress(MONGO_HOST, MONGO_PORT))))
                        .build()
        );

        MongoDatabase database = this.mongoClient.getDatabase(databaseName);
        this.collection = database.getCollection(collectionName);
    }

    /**
     * Retrieves the oldest date in the collection, and the most recent date in the collection.
     * The date is represented as an integer YYYYMMDDHH, i.e.:
     * 2010020400 would be year 2010, month 02 (February), day 04, and hour 00.
     * @return
     */
    public int[] getMinAndMaxDates() {
        log.info("Getting min and max dates for {}.{}", this.databaseName, this.collectionName);
        AggregateIterable<Document> results = this.collection.aggregate(
                List.of(
                        Aggregates.group(
                                null,
                                Accumulators.max("max_date", "$year_month_day_hour")
                        ),
                        Aggregates.group(
                                null,
                                Accumulators.max("min_date", "$year_month_day_hour")
                        )
                )
        );

        Document first = results.first();
        if (first != null) {
            Integer min = first.getInteger("min_date");
            Integer max = first.getInteger("max_date");
            if (min != null && max != null) {
                log.info("Successfully found min date {} and max date {}", min, max);
                return new int[] {min, max};
            }
        }
        log.error("Unable to find min and max dates!");
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

    public void query(String databaseName, String collectionName, String field, String gisJoin, String period) {

        System.err.println("Executing MongoDB Query...");



        AggregateIterable<Document> filtered = collection.aggregate(
                List.of(
                        Aggregates.match(Aggregates.match(Filters.and(
                                Filters.eq("gis_join", "G4100470"),
                                Filters.eq("timestep", 0)
                        )))
                )
        );


        collection.aggregate(
                Arrays.asList(
                        Aggregates.match(Filters.and(
                                Filters.eq("gis_join", "G4100470"),
                                Filters.eq("timestep", 0)
                        )),
                        Aggregates.bucket(
                                "$year_month_day_hour",
                                Arrays.asList(
                                        2010010100,
                                        2010010700,
                                        2010011400,
                                        2010012100,
                                        2010012800,
                                        2010020400,
                                        2010021100,
                                        2010021800,
                                        2010022500
                                ),
                                new BucketOptions()
                                        .defaultBucket(2010030100)
                                        .output(
                                                Accumulators.max("max_precip_kg_sq_meter", "$precipitable_water_kg_per_squared_meter")
                                        )
                        )

                )
        ).forEach(
                x -> System.out.println(x.toJson())
        );

        mongoClient.close();
    }
}
