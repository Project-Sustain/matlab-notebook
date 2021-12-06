package org.sustain.matlab.eva;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.CrossOrigin;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.mathworks.engine.*;
import org.sustain.mongodb.MongoQuery;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class ExtremeValueAnalysis {

    public static Logger log = LoggerFactory.getLogger(ExtremeValueAnalysis.class);

    /**
     * Calculates Extreme Value Analysis on the extrema specified by the request.
     * The extrema are gathered by executing a MongoDB bucket query on a requested field
     * using period blocks on the year_month_day_hour field. These extrema are then input into
     * the MATLAB ProNEVA package, which is executed with the Java MATLAB Engine.
     * @param request EvaRequest object specifying field, gisJoin, and period over which to run EVA.
     * @return The results from ProNEVA, in the form of a EvaResponse object.
     */
    public static EvaResponse extremeValueAnalysisRequest(EvaRequest request, MatlabEngine engine) {

        log.info("Request: {}", request);
        MongoQuery mongoQuery = new MongoQuery("sustaindb", request.collection);
        List<Long> minAndMaxDates = mongoQuery.getMinAndMaxDates(request.gisJoin);
        Long min = minAndMaxDates.get(0);
        Long max = minAndMaxDates.get(1);
        List<Long> bucketBounds = getDateBoundariesByPeriod(request.period, min, max);
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

    public static EvaResponse exampleEvaRequest(MatlabEngine engine) {
        /*List<Double> blockExtrema = new ArrayList<Double>(List.of(
                17.46,17.68,17.76,18.14,17.73,17.48,17.58,17.68,17.34,17.33,17.53,17.52,17.27,17.68,17.96,
                17.35,17.82,18.10,17.09,17.06,18.02,18.37,17.13,17.26,17.55,17.25,18.28,18.52,18.43,17.76,
                18.68,18.22,17.85,17.04,18.22,17.97,17.62,17.62,18.68,19.00,18.51,18.69,18.44,18.39,18.12,
                18.61,19.12,18.69,18.03,17.87,18.14,18.42,19.83,17.86,17.97,18.93,19.27
        ));*/
        List<Double> blockExtrema = new ArrayList<Double>(List.of(
                320.34999999999997,
                320.34999999999997,
                310.95,
                305.34999999999997,
                317.54999999999995,
                317.04999999999995,
                320.34999999999997,
                316.45,
                319.84999999999997,
                319.84999999999997,
                318.15,
                317.54999999999995,
                317.04999999999995,
                298.15,
                319.25,
                318.15,
                320.95,
                318.15,
                317.54999999999995,
                317.54999999999995,
                317.54999999999995,
                317.54999999999995,
                316.45,
                317.54999999999995,
                320.95,
                317.54999999999995,
                318.75,
                318.75,
                318.15,
                317.54999999999995,
                317.54999999999995,
                318.15,
                318.15,
                316.45,
                319.25,
                318.75,
                319.84999999999997,
                318.75,
                319.84999999999997,
                319.25,
                319.84999999999997,
                319.84999999999997,
                318.15,
                318.75,
                319.25,
                320.34999999999997,
                319.25,
                318.75,
                318.15,
                319.84999999999997,
                318.15,
                319.25,
                319.25,
                319.25,
                319.84999999999997,
                320.95,
                323.15,
                318.15,
                318.15,
                318.75,
                320.34999999999997,
                322.54999999999995,
                319.25,
                318.75,
                320.34999999999997,
                317.04999999999995,
                318.15,
                319.84999999999997,
                318.15,
                320.34999999999997,
                317.54999999999995,
                319.84999999999997,
                320.95,
                319.84999999999997,
                319.25,
                319.25,
                318.75,
                320.95,
                319.84999999999997,
                321.45,
                319.84999999999997,
                320.34999999999997,
                320.95,
                321.45,
                319.84999999999997,
                319.25,
                320.95,
                320.95
        ));

        log.info("Block Extrema: {}", blockExtrema);
        EvaResults results = EvaLauncher.launchExtremeValueAnalysis(
                engine,
                blockExtrema.stream().mapToDouble(Double::doubleValue).toArray()
        );
        log.info("EVA Results: {}", results);
        return new EvaResponse("example_collection", "example_field", results);
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
    public static List<Long> getDateBoundariesByPeriod(String period, Long minDateNumber, Long maxDateNumber) {
        List<Long> boundaries = new ArrayList<>();
        boundaries.add(minDateNumber); // start with minimum date as first boundary

        try {
            SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHHHH");
            Date minDate = format.parse(Long.toString(minDateNumber));
            Date maxDate = format.parse(Long.toString(maxDateNumber));
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
                boundaries.add(Long.parseLong(format.format(boundaryDate)));
            }
        } catch (ParseException e) {
            log.error("Unable to parse date: {}", e.getMessage());
        }

        return boundaries;
    }
}
