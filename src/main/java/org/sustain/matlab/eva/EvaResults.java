package org.sustain.matlab.eva;

import java.util.List;

public class EvaResults {

    public Boolean errorOccurred;
    public String errorMessage;
    public List<List<Double>> extremeValueAnalysisResults;

    public EvaResults(Boolean errorOccurred, String errorMessage, List<List<Double>> extremeValueAnalysisResults) {
        this.errorOccurred = errorOccurred;
        this.errorMessage = errorMessage;
        this.extremeValueAnalysisResults = extremeValueAnalysisResults;
    }

    @Override
    public String toString() {
        return "EvaResults:\n" +
                String.format("\terrorOccurred: %b\n", this.errorOccurred) +
                String.format("\terrorMessage: %s\n", this.errorMessage);
    }
}
