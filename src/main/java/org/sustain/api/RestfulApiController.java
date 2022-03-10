package org.sustain.api;

import com.mathworks.engine.EngineException;
import com.mathworks.engine.MatlabEngine;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.sustain.matlab.eva.EvaRequest;
import org.sustain.matlab.eva.EvaResponse;
import org.sustain.matlab.eva.ExtremeValueAnalysis;

import javax.annotation.PreDestroy;

@RestController
public class RestfulApiController implements InitializingBean  {

    public static Logger log = LoggerFactory.getLogger(RestfulApiController.class);

    private static MatlabEngine engine;

    @Override
    public void afterPropertiesSet() {
        try {
            log.info("Starting MATLAB engine...");
            String[] matlabEngineOptions = new String[] {
                    "-nodisplay",   // Do not display any X commands. The MATLAB desktop will not be started.
                    "-nosplash"     // Do not display the splash screen during startup.
            };
            engine = MatlabEngine.startMatlab(matlabEngineOptions);
            log.info("MATLAB engine successfully started");
        } catch (Exception e) {
            log.error("Unable to start MATLAB engine from afterPropertiesSet(): {}", e.getMessage());
            System.exit(1);
        }
    }

    @PreDestroy
    public void destroy() {
        try {
            log.info("Shutting down MATLAB engine...");
            engine.close();
            log.info("MATLAB engine successfully shut down");
        } catch (EngineException e) {
            log.error("Unable to shut down MATLAB engine gracefully: {}", e.getMessage());
        }
    }

    @PostMapping("/matlab_notebook/echo")
    @CrossOrigin(origins = "http://localhost:3000")
    public String echoPostRequest(@RequestBody String request) {
        log.info("Received echo POST request: {}", request);
        return request;
    }

    /**
     * Calculates Extreme Value Analysis on the extrema specified by the request.
     * The extrema are gathered by executing a MongoDB bucket query on a requested field
     * using period blocks on the year_month_day_hour field. These extrema are then input into
     * the MATLAB ProNEVA package, which is executed with the Java MATLAB Engine.
     * @param request EvaRequest object specifying field, gisJoin, and period over which to run EVA.
     * @return The results from ProNEVA, in the form of a EvaResponse object.
     */
    @PostMapping("/matlab_notebook/eva")
    @CrossOrigin(origins = "http://localhost:3000")
    public EvaResponse extremeValueAnalysisRequest(@RequestBody EvaRequest request) {
        log.info("Extreme Value Analysis Request: {}", request);
        return ExtremeValueAnalysis.extremeValueAnalysisRequest(request, engine);
    }

    @PostMapping("/matlab_notebook/eva/example")
    @CrossOrigin(origins = "http://localhost:3000")
    public EvaResponse extremeValueAnalysisExampleRequest() {
        log.info("Extreme Value Analysis Request for default example (US_Temp.txt)");
        return ExtremeValueAnalysis.exampleEvaRequest(engine);
    }

}
