package org.sustain.matlab.eva;

import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class EvaControllerTest {

    @Test
    public void testGetDateBoundariesByPeriod() {

        Long minDate = 202101010000L;
        Long maxDate = 202110230600L;
        List<Long> expected = new ArrayList<>(List.of(
                202101010000L,
                202102010000L,
                202103010000L,
                202104010000L,
                202105010000L,
                202106010000L,
                202107010000L,
                202108010000L,
                202109010000L,
                202110010000L,
                202111010000L,
                202112010000L
        ));

        List<Long> actual = EvaController.getDateBoundariesByPeriod("month", minDate, maxDate);
        System.out.println(actual);
        assertEquals(expected, actual);
    }
}
