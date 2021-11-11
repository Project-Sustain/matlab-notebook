import org.sustain.mongodb.MongoQuery;

public class Main {

    public static void main(String[] programArgs) {
        MongoQuery testQuery = new MongoQuery("sustaindb", "noaa_nam");
        testQuery.getMinAndMaxDates();
    }

}
