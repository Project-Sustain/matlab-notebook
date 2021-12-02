import React, {useEffect} from 'react';
import * as d3 from 'd3';

export default function Results(props) {

    var svgRef = React.createRef();

    let svgWidth  = 500,
        svgHeight = 500;

    // Axis tick values/labels
    let tickLabels = [2, 5, 10, 20, 50, 100]; // Actual tick values will be log10(tickLabels)
    let tickValuesArray = [];
    let tickValues = {};
    for (let tickLabel of tickLabels) {
        tickValuesArray.push(Math.log10(tickLabel));
        tickValues[Math.log10(tickLabel)] = tickLabel;
    }

    let xAxisConfig = {
        minValue: 0.0,
        maxValue: 2.0,
        rightShift: 70,
        downShift: svgHeight/2 + 10,
        linearScale: null
    };

    let yAxisConfig = {
        minValue: 0,
        maxValue: 100,
        rightShift: 70,
        downShift: 10,
        linearScale: null
    };

    function setupXAxis(svg, title) {
        // Create Linear Scale
        xAxisConfig.linearScale = d3.scaleLinear()
            .domain([xAxisConfig.minValue, xAxisConfig.maxValue])
            .range([0, svgWidth-100]);

        // Create X-Axis and scale it to the Linear Scale
        let xAxis = d3.axisBottom()
            .tickValues(tickValuesArray)
            .scale(xAxisConfig.linearScale)
            .tickFormat(d => {
                return tickValues[d];
            });

        // Add X-Axis to SVG
        svg.select("g#xAxis")
            .attr("transform", `translate(${xAxisConfig.rightShift},${xAxisConfig.downShift})`) // shift move it down and right
            .call(xAxis);

        // Add label to X-Axis
        svg.select("text#xAxisLabel")
            .attr("transform", `translate(${svgWidth/2 - 80},${xAxisConfig.downShift + 50})`)
            .style("font-size", "12px")
            .text(title);
    }

    function setupYAxis(svg, title, data) {
        // Find max of data array's y-points
        yAxisConfig.maxValue = d3.max(data, function (d) {
            return d[1];
        });

        yAxisConfig.minValue = d3.min(data, function (d) {
            return d[1];
        });

        // Create Linear Scale
        yAxisConfig.linearScale = d3.scaleLinear()
            .domain([yAxisConfig.minValue, yAxisConfig.maxValue])
            .range([svgHeight/2, 0]);

        // Create Y-Axis and scale it to the Linear Scale
        let yAxis = d3.axisLeft().scale(yAxisConfig.linearScale);

        // Add Y-Axis to SVG
        svg.select("g#yAxis")
            .attr("transform", `translate(${yAxisConfig.rightShift},${yAxisConfig.downShift})`)
            .call(yAxis);

        // Add label to Y-Axis
        svg.select("text#yAxisLabel")
            .attr("transform", `translate(${20},${svgHeight/2-50}) rotate(-90)`)
            .style("font-size", "12px")
            .text(title);
    }

    /**
     * Adds blank default "g" elements to the SVG so that we can reuse them by
     * selecting them by their ids at a later time, during rerender().
     */
    let setup = () => {
        let svg = d3.select(svgRef.current);
        svg.append("g").attr("id", "xAxis");
        svg.append("g").attr("id", "yAxis");
        svg.append("text").attr("id", "xAxisLabel")
        svg.append("text").attr("id", "yAxisLabel")
    };

    let rerender = () => {
        let returnLevelConfidenceInterval50 = props.response["returnLevelConfidenceInterval50"];
        let returnLevelConfidenceInterval05 = props.response["returnLevelConfidenceInterval05"];
        let returnLevelConfidenceInterval95 = props.response["returnLevelConfidenceInterval95"];
        let median = props.response["median"];
        let observations = props.response["observations"];

        // Sort by x values
        returnLevelConfidenceInterval50.sort((a, b) => (a[0]) - b[0]);
        returnLevelConfidenceInterval05.sort((a, b) => (a[0]) - b[0]);
        returnLevelConfidenceInterval95.sort((a, b) => (a[0]) - b[0]);
        median.sort((a, b) => (a[0]) - b[0]);

        let svg = d3.select(svgRef.current);
        svg.attr("width", svgWidth);
        svg.attr("height", svgHeight);
        setupXAxis(svg, `Return Period (${props.returnPeriod})`);
        setupYAxis(svg, `Return Level (${props.unit})`, observations);

        let line = d3.line()
            .x(d => xAxisConfig.linearScale(d[0]) + xAxisConfig.rightShift)
            .y(d => yAxisConfig.linearScale(d[1]) + yAxisConfig.downShift);

        // Upper 95 % Confidence Interval Line
        svg.append("path")
            .data([returnLevelConfidenceInterval95])
            .attr("d", d => line(d))
            .attr("stroke", "#13A83D")
            .style("stroke-dasharray", ("3,4"))
            .attr("stroke-width", 1.5)
            .attr("fill", "none");

        // Lower 5 % Confidence Interval Line
        svg.append("path")
            .data([returnLevelConfidenceInterval05])
            .attr("d", d => line(d))
            .attr("stroke", "#13A83D")
            .attr("stroke-width", 1.5)
            .style("stroke-dasharray", ("3,4"))
            .attr("fill", "none");

        // Middle 50 % Confidence Interval Line
        svg.append("path")
            .data([returnLevelConfidenceInterval50])
            .attr("d", d => line(d))
            .attr("stroke", "#CC0000")
            .attr("stroke-width", 1.2)
            .attr("fill", "none");

        // Median Line
        svg.append("path")
            .data([median])
            .attr("d", d => line(d))
            .attr("stroke", "#000000")
            .attr("stroke-width", 1.0)
            .style("stroke-dasharray", ("5,2"))
            .attr("fill", "none");

        // Observations Scatter-plot
        svg.append("g")
            .selectAll("dot")
            .data(observations)
            .enter()
            .append("circle")
            .attr("cx", function (d) { return xAxisConfig.linearScale(d[0]) + xAxisConfig.rightShift; } )
            .attr("cy", function (d) { return yAxisConfig.linearScale(d[1]) + yAxisConfig.downShift; } )
            .attr("r", 1.7)
            .style("fill", "#0050EE");

        // Append legend
        svg.append("circle").attr("cx",svgWidth-100).attr("cy",130).attr("r", 3).style("fill", "#13A83D")
        svg.append("circle").attr("cx",svgWidth-100).attr("cy",160).attr("r", 3).style("fill", "#CC0000")
        svg.append("circle").attr("cx",svgWidth-100).attr("cy",190).attr("r", 3).style("fill", "#000000")
        svg.append("circle").attr("cx",svgWidth-100).attr("cy",220).attr("r", 3).style("fill", "#0050EE")
        svg.append("text").attr("x", svgWidth-80).attr("y", 130).text("90% CI").style("font-size", "12px").attr("alignment-baseline","middle")
        svg.append("text").attr("x", svgWidth-80).attr("y", 160).text("Median").style("font-size", "12px").attr("alignment-baseline","middle")
        svg.append("text").attr("x", svgWidth-80).attr("y", 190).text("MLE").style("font-size", "12px").attr("alignment-baseline","middle")
        svg.append("text").attr("x", svgWidth-80).attr("y", 220).text("Observations").style("font-size", "12px").attr("alignment-baseline","middle")
    }

    useEffect(setup);
    useEffect(rerender);

    return (
        <div>
            <svg ref={svgRef}/>
        </div>
    );
}