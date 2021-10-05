package org.sustain.matlab.eva;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.mathworks.engine.*;
import com.mathworks.javaenginecore.*;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Arrays;
import java.util.Scanner;
import java.util.concurrent.ExecutionException;

@RestController
public class EvaController {

    public static Logger log = LoggerFactory.getLogger(EvaController.class);

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



        log.info("Received Extreme Value Analysis request: {}", request);
        log.info("Executing simple MATLAB script: {}", request);
        try {
            MatlabEngine matlabEngine = MatlabEngine.startMatlab();

            matlabEngine.eval("cd matlab_testing/");
            matlabEngine.eval("test()");
            matlabEngine.close();

        } catch(EngineException e) {
            e.printStackTrace();
        } catch(InterruptedException e) {
            e.printStackTrace();
        } catch(ExecutionException e) {
            e.printStackTrace();
        }

        log.info("Finished executing MATLAB script, saved results to matlab_testing/output.csv");
        log.info("Loading matlab_testing/output.csv and returning results");

        Integer[][] results = new Integer[2][2];
        try {
            Scanner fileScanner = new Scanner(new File("matlab_testing/output.csv"));
            for (int i = 0; i < 2; i++) {
                String[] lineParts = fileScanner.nextLine().split(",");
                for (int j = 0; j < 2; j++) {
                    results[i][j] = Integer.parseInt(lineParts[j]);
                }
            }

            fileScanner.close();
        } catch (FileNotFoundException e) {
            log.error("Output file \"matlab_testing/output.csv\" doesn't exist! {}", e.getMessage());
        }
        return new EvaResponse(request.collection, request.field, results);
    }

}
