package org.sustain.matlab.eva;

import java.util.List;

public class EvaRequest {

    public String collection;
    public String field;
    public String period;
    public List<Double> extrema;

    @Override
    public String toString() {
        return "EvaRequest:\n" +
                String.format("\tcollection: %s\n", this.collection) +
                String.format("\tfield: %s\n", this.field) +
                String.format("\tperiod: %s\n", this.period) +
                String.format("\textrema: %s\n", this.extrema);
    }
}
