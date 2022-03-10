package org.sustain.matlab.eva;

import org.junit.jupiter.api.Test;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.fail;

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

            List<Date> actual = ExtremeValueAnalysis.getDateBoundariesByPeriod("month", minDate, maxDate);
            for (Date date: actual) {
                System.out.println(date.toString());
            }
            assertEquals(expected, actual);
        } catch (ParseException e) {
            System.err.println("Caught ParseException: " + e.getMessage());
            fail();
        }

    }
}
