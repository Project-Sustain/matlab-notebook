package org.sustain.matlab.eva;

import com.mathworks.engine.MatlabEngine;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sustain.mongodb.MongoQuery;

import java.util.*;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

public class EvaLauncher {

    public static Logger log = LoggerFactory.getLogger(MongoQuery.class);

    public static EvaResults launchExtremeValueAnalysis(MatlabEngine engine, double[] extrema) {
        log.info("Launching Extreme Value Analysis with ProNEVA...");
        try {
            engine.eval("cd ProNEVA/");
            Object[] outputs = engine.feval(7, "runProNEVA", (Object) extrema);
            engine.eval("cd ../../");
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
