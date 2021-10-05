package org.sustain.mongodb;

import com.mongodb.MongoClientSettings;
import com.mongodb.MongoException;
import com.mongodb.ServerAddress;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoCollection;

import com.mongodb.client.model.*;
import org.bson.BsonDocument;
import org.bson.BsonInt64;
import org.bson.Document;
import org.bson.conversions.Bson;

import java.util.Arrays;

public class Query {

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

    public static void query() {

        String uri = "mongodb://lattice-100:27018";
        MongoClient mongoClient = MongoClients.create(
                MongoClientSettings.builder()
                        .applyToClusterSettings(builder ->
                                builder.hosts(Arrays.asList(new ServerAddress("lattice-100", 27018))))
                        .build()
        );


        System.err.println("Executing MongoDB Query...");

        MongoDatabase database = mongoClient.getDatabase("sustaindb");
        MongoCollection<Document> collection = database.getCollection("noaa_nam");


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
                                                new BsonField("max_precip_kg_sq_meter",
                                                        new Document("$max", Accumulators.max("_max",
                                                                "$precipitable_water_kg_per_squared_meter")
                                                        )
                                                )
                                        )
                        )

                )
        ).forEach(
                x -> System.out.println(x.toJson())
        );

        mongoClient.close();
    }

    public static void main(String[] args) {
        query();
    }

}
