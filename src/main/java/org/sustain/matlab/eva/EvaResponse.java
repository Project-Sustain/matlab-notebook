package org.sustain.matlab.eva;

import java.util.ArrayList;
import java.util.List;

public class EvaResponse {

    public String collection;
    public String field;
    public Boolean errorOccurred;
    public String errorMessage;
    public List<Double[]> returnLevelConfidenceInterval50;
    public List<Double[]> returnLevelConfidenceInterval05;
    public List<Double[]> returnLevelConfidenceInterval95;
    public List<Double[]> median;
    public List<Double[]> observations;

    public EvaResponse(String collection, String field, EvaResults evaResults) {
        this.collection = collection;
        this.field = field;
        this.errorOccurred = evaResults.errorOccurred;
        this.errorMessage = evaResults.errorMessage;

        if (!evaResults.errorOccurred) {
            List<List<Double>> results = evaResults.extremeValueAnalysisResults;
            List<Double> observationsX = results.get(0);
            List<Double> observationsY = results.get(1);
            this.returnLevelConfidenceInterval50 = new ArrayList<>();
            this.returnLevelConfidenceInterval05 = new ArrayList<>();
            this.returnLevelConfidenceInterval95 = new ArrayList<>();
            this.median = new ArrayList<>();
            this.observations = new ArrayList<>();

            // Populate each result list with [x,y] points. The x point is taken from the
            // Return Period Vector (including value of ~1), and the y point is the calculated
            // Return Level Confidence Interval/Median value, or observation.
            int size = results.get(2).size();
            for (int i = 0; i < size; i++) {
                double x = results.get(2).get(i);
                this.returnLevelConfidenceInterval50.add(new Double[]{x, results.get(3).get(i)});
                this.returnLevelConfidenceInterval05.add(new Double[]{x, results.get(4).get(i)});
                this.returnLevelConfidenceInterval95.add(new Double[]{x, results.get(5).get(i)});
                this.median.add(new Double[]{x, results.get(6).get(i)});
            }

            // Populate observations
            for (int i = 0; i < observationsX.size(); i++) {
                this.observations.add(new Double[]{observationsX.get(i), observationsY.get(i)});
            }
        }
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("EvaResponse:\n");
        sb.append(String.format("\tcollection: %s\n", this.collection));
        sb.append(String.format("\tfield: %s\n", this.field));
        sb.append(String.format("\tfield: %b\n", this.errorOccurred));
        sb.append(String.format("\tfield: %s\n", this.errorMessage));

        if (!this.errorOccurred) {
            sb.append("\treturnLevelConfidenceInterval50: [\n");
            for (Double[] values: this.returnLevelConfidenceInterval50) {
                sb.append(String.format("\t  [x=%.2f, y=%.2f]\n", values[0], values[1]));
            }
            sb.append("\t]\n");

            sb.append("\treturnLevelConfidenceInterval05: [\n");
            for (Double[] values: this.returnLevelConfidenceInterval05) {
                sb.append(String.format("\t  [x=%.2f, y=%.2f]\n", values[0], values[1]));
            }
            sb.append("\t]\n");

            sb.append("\treturnLevelConfidenceInterval95: [\n");
            for (Double[] values: this.returnLevelConfidenceInterval95) {
                sb.append(String.format("\t  [x=%.2f, y=%.2f]\n", values[0], values[1]));
            }
            sb.append("\t]\n");

            sb.append("\tmedian: [\n");
            for (Double[] values: this.median) {
                sb.append(String.format("\t  [x=%.2f, y=%.2f]\n", values[0], values[1]));
            }
            sb.append("\t]\n");

            sb.append("\tobservations: [\n");
            for (Double[] values: this.observations) {
                sb.append(String.format("\t  [x=%.2f, y=%.2f]\n", values[0], values[1]));
            }
            sb.append("\t]\n");
        }
        return sb.toString();
    }

}
