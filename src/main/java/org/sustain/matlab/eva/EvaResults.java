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
        StringBuilder sb = new StringBuilder("EvaResults:\n");
        sb.append(String.format("\terrorOccurred: %b\n", this.errorOccurred));
        sb.append(String.format("\terrorMessage: %s\n", this.errorMessage));
        sb.append("\textremeValueAnalysisResults:\n");
        for (List<Double> resultList: this.extremeValueAnalysisResults) {
            sb.append(resultList);
            sb.append("\n");
        }
        return sb.toString();
    }
}
