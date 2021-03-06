package org.sustain.matlab.eva;

import org.junit.jupiter.api.Test;
import org.sustain.mongodb.MongoQuery;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.fail;
import static org.sustain.matlab.eva.ExtremeValueAnalysis.getDateBoundariesByPeriod;

public class EvaControllerTest {

    @Test
    public void testGetDateBoundariesByPeriod() {

        try {
            SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            Date minDate = format.parse("2015-12-07T10:38:17.498Z");
            Date maxDate = format.parse("2016-03-07T10:38:17.498Z");

            List<Date> expected = new ArrayList<>(List.of(
                    format.parse("2015-12-07T10:38:17.498Z"),
                    format.parse("2016-01-07T10:38:17.498Z"),
                    format.parse("2016-02-07T10:38:17.498Z"),
                    format.parse("2016-03-07T10:38:17.498Z")
            ));

            List<Date> actual = getDateBoundariesByPeriod("month", minDate, maxDate);
            for (Date date: actual) {
                System.out.println(date.toString());
            }
            assertEquals(expected, actual);
        } catch (ParseException e) {
            System.err.println("Caught ParseException: " + e.getMessage());
            fail();
        }

    }

    @Test
    public void testGetBuckets() {
        MongoQuery testQuery = new MongoQuery("sustaindb", "noaa_nam");
        List<Date> minAndMaxDates = testQuery.getMinAndMaxDates("G4100470");

        List<Date> boundaries = getDateBoundariesByPeriod("month", minAndMaxDates.get(0), minAndMaxDates.get(1));
        testQuery.findBlockExtrema("PRESSURE_AT_SURFACE_PASCAL", "G4100470", 0, boundaries);
    }
}
