package org.sustain.matlab.eva;

import java.util.List;

public class EvaRequest {

    public String collection;
    public String field;
    public String gisJoin;
    public String period;
    public Integer timestep;

    @Override
    public String toString() {
        return "EvaRequest:\n" +
                String.format("\tcollection: %s\n", this.collection) +
                String.format("\tfield: %s\n", this.field) +
                String.format("\tgisJoin: %s\n", this.gisJoin) +
                String.format("\tperiod: %s\n", this.period) +
                String.format("\ttimestep: %s\n", this.timestep);
    }
}
