package org.sustain.matlab.eva;

import org.springframework.beans.factory.InitializingBean;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.mathworks.engine.*;
import org.sustain.mongodb.MongoQuery;

import javax.annotation.PreDestroy;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

@RestController
@Component
public class EvaController implements InitializingBean {

    public static Logger log = LoggerFactory.getLogger(EvaController.class);

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

    /**
     * Calculates Extreme Value Analysis on the extrema specified by the request.
     * The extrema are gathered by executing a MongoDB bucket query on a requested field
     * using period blocks on the year_month_day_hour field. These extrema are then input into
     * the MATLAB ProNEVA package, which is executed with the Java MATLAB Engine.
     * @param request EvaRequest object specifying field, gisJoin, and period over which to run EVA.
     * @return The results from ProNEVA, in the form of a EvaResponse object.
     */
    @PostMapping("/eva")
    public EvaResponse extremeValueAnalysisRequest(@RequestBody EvaRequest request) {

        log.info("Request: {}", request);
        MongoQuery mongoQuery = new MongoQuery("sustaindb", request.collection);
        List<Integer> minAndMaxDates = mongoQuery.getMinAndMaxDates();
        Integer min = minAndMaxDates.get(0);
        Integer max = minAndMaxDates.get(1);
        List<Integer> bucketBounds = getDateBoundariesByPeriod(request.period, min, max);
        List<Double> blockExtrema = mongoQuery.findBlockExtrema(
                request.field, request.gisJoin, request.timestep, bucketBounds
        );
        mongoQuery.mongoClient.close();
        log.info("Block Extrema: {}", blockExtrema);

        EvaResults results = EvaLauncher.launchExtremeValueAnalysis(
                engine,
                blockExtrema.stream().mapToDouble(Double::doubleValue).toArray()
        );
        log.info("EVA Results: {}", results);
        return new EvaResponse(request.collection, request.field, results);
    }

    /**
     * Creates bucket boundaries for the period blocks used to get extrema. One extreme value is retrieved from
     * each of the blocks in the period.
     * @param period A String with one of the values ["year", "month", "day", "hour"]
     * @param minDateNumber The beginning date of the range of periods, in YYYYMMDDHH format.
     * @param maxDateNumber The end date of the range of periods, in YYYYMMDDHH format.
     * @return A list of inclusive/exclusive period boundaries, where the first element is inclusive and the next is exclusive.
     * For example, if the list [2010010100, 2010010200, 2010010300] is returned, then the first bucket period is
     * from Jan 1, 2010 to Jan 31, 2010, and the second bucket period is from Feb 1, 2010 to Feb 27/28, 2010.
     */
    public static List<Integer> getDateBoundariesByPeriod(String period, Integer minDateNumber, Integer maxDateNumber) {
        List<Integer> boundaries = new ArrayList<>();
        boundaries.add(minDateNumber); // start with minimum date as first boundary

        try {
            SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHH");
            Date minDate = format.parse(Integer.toString(minDateNumber));
            Date maxDate = format.parse(Integer.toString(maxDateNumber));
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(minDate);

            // Determine period increment amount
            int field = Calendar.YEAR;
            int amount = 1;
            switch (period.trim().toLowerCase()) {
                case "year":
                    break; // default
                case "month":
                    field = Calendar.MONTH;
                    break;
                case "day":
                    field = Calendar.DAY_OF_YEAR;
                    break;
                case "hour":
                    field = Calendar.HOUR_OF_DAY;
                    amount = 3;
                    break;
                default:
                    log.error("Period \"{}\" not supported, defaulting to yearly periods", period);
            }

            // Add intermediate date boundaries
            while (calendar.getTime().before(maxDate)) {
                calendar.add(field, amount);
                Date boundaryDate = calendar.getTime();
                boundaries.add(Integer.parseInt(format.format(boundaryDate)));
            }
        } catch (ParseException e) {
            log.error("Unable to parse date: {}", e.getMessage());
        }

        return boundaries;
    }
}
