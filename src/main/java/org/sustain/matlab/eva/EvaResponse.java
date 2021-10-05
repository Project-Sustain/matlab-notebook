package org.sustain.matlab.eva;

public class EvaResponse {

    public String collection;
    public String field;
    public Integer[][] resultingMatrix;

    public EvaResponse() {
        this("default_collection", "default_field", null);
    }

    public EvaResponse(String collection, String field, Integer[][] resultingMatrix) {
        this.collection = collection;
        this.field = field;
        this.resultingMatrix = resultingMatrix;
    }

    @Override
    public String toString() {
        return "EvaResponse:\n" +
                String.format("  collection: %s\n", this.collection) +
                String.format("  field: %s\n", this.field);
    }

}
