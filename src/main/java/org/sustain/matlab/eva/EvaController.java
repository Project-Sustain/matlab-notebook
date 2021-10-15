package org.sustain.matlab.eva;

import org.springframework.beans.factory.InitializingBean;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.mathworks.engine.*;
import org.sustain.mongodb.Query;

import javax.annotation.PreDestroy;
import java.util.List;

@RestController
@Component
public class EvaController implements InitializingBean {

    public static Logger log = LoggerFactory.getLogger(EvaController.class);

    private static MatlabEngine engine;

    @Override
    public void afterPropertiesSet() throws Exception {
        try {
            log.info("Starting MATLAB engine...");
            engine = MatlabEngine.startMatlab();
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

    @GetMapping("/")
    public String index() {
        return "Welcome to SUSTAIN MATLAB Notebook\n" +
                "To get started, please send POST request to:\n" +
                "/eva with the following JSON body:\n" +
                "{\n\t\"collection\": <collection>,\n" +
                "\t\"field\": <collection_field>\n" +
                "}\n";
    }

    @PostMapping("/eva")
    public EvaResponse extremeValueAnalysisRequest(@RequestBody EvaRequest request) {

        Query extremaQuery = new Query("sustaindb", request.collection);
        int[] minAndMaxDates = extremaQuery.getMinAndMaxDates();
        List<Integer> bucketBounds = getBucketBounds(minAndMaxDates, request.period);

        /*
        log.info("Received Extreme Value Analysis request: {}", request);
        EvaResults results = EvaLauncher.launchExtremeValueAnalysis(
                engine,
                request.extrema.stream().mapToDouble(i -> i).toArray()
        );
        log.info("Received results: {}", results);
         */
        return new EvaResponse(request.collection, request.field, null);
    }

    public List<Integer> getBucketBounds(int[] minAndMaxDates, String period) {
        log.info("Creating bucket bounds using a period of {}", period);
        return null;
    }


}
