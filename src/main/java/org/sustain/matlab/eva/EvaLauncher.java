package org.sustain.matlab.eva;

import com.mathworks.engine.MatlabEngine;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

public class EvaLauncher {

    public static EvaResults launchExtremeValueAnalysis(MatlabEngine engine, double[] extrema) {
        try {

            engine.eval("cd /Users/carlsonc/Jetbrains/IntelliJ/matlab-notebook/ProNEVA/");
            Object[] outputs = engine.feval(7, "runProNEVA", (Object) extrema);

            // Collect results into List<Double>
            List<List<Double>> extremeValueAnalysisResults = new ArrayList<>();
            for (Object genericOutput : outputs) {
                extremeValueAnalysisResults.add(Arrays.stream((double[]) genericOutput)
                        .boxed()
                        .collect(Collectors.toList())
                );
            }
            return new EvaResults(false, null, extremeValueAnalysisResults);
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            return new EvaResults(true, e.getMessage(), null);
        }
    }

}
