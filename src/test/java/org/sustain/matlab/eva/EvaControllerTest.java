package org.sustain.matlab.eva;

import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class EvaControllerTest {

    @Test
    public void testGetDateBoundariesByPeriod() {

        Integer minDate = 2010010100;
        Integer maxDate = 2010010400;
        List<Integer> expected = new ArrayList<>(List.of(
                minDate,
                2010010200,
                2010010300,
                maxDate
        ));

        List<Integer> actual = EvaController.getDateBoundariesByPeriod("day", minDate, maxDate);
        assertEquals(expected, actual);
    }
}
