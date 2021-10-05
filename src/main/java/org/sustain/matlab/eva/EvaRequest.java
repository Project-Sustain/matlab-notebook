package org.sustain.matlab.eva;

public class EvaRequest {

    public String collection;
    public String field;

    @Override
    public String toString() {
        return "EvaRequest:\n" +
                String.format("  collection: %s\n", this.collection) +
                String.format("  field: %s\n", this.field);
    }
}
