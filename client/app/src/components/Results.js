import React, {useEffect, useState} from 'react';
import * as d3 from 'd3';

export default function Results() {

    var svgRef = React.createRef();

    var data = [[12, 200], [20, 320], [66, 145], [53, 80], [24, 99], [80, 19], [10, 243], [33, 301], [100, 15]];
    var margin = 20;
    var svgWidth = 700,
        svgHeight = 500;

    let xAxisConfig = {
        minValue: 0,
        maxValue: 100,
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
        let xAxis = d3.axisBottom().scale(xAxisConfig.linearScale);

        // Add X-Axis to SVG
        svg.select("g#xAxis")
            .attr("transform", `translate(${xAxisConfig.rightShift},${xAxisConfig.downShift})`)
            .call(xAxis);

        // Add label to X-Axis
        svg.select("text#xAxisLabel")
            .attr("transform", `translate(${svgWidth/2 - 50},${xAxisConfig.downShift + 50})`)
            .text(title);
    }

    function setupYAxis(svg, title) {
        // Find max of data array's y-points
        yAxisConfig.maxValue = d3.max(data, function (d) {
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
            .attr("transform", `translate(${20},${svgHeight/2-100}) rotate(-90)`)
            .text(title);
    }

    function plotScatterPlot(svg, points) {
        svg.selectAll("dot")
            .data(points)
            .enter().append("circle")
            .attr("r", 2)
            .attr("cx", function (d) {
                return xAxisConfig.linearScale(d[0]) + xAxisConfig.rightShift;
            })
            .attr("cy", function (d) {
                return yAxisConfig.linearScale(d[1]) + yAxisConfig.downShift;
            })
            .attr("stroke", "#3646f5")
            .attr("stroke-width", 1.5)
            .attr("fill", "#FFFFFF");
    }

    /**
     * Plots a solid line on the SVG element by connecting the points given.
     * @param svg Reference to our SVG element
     * @param points Array of points; must be an array in the form [ [x1,y1], [x2,y2], ..., [xn, yn] ]
     */
    function plotSolidLine(svg, points) {

        let line = d3.line()
            .x(d => xAxisConfig.linearScale(d[0]) + xAxisConfig.rightShift)
            .y(d => yAxisConfig.linearScale(d[1]) + yAxisConfig.downShift);

        // Make a d3 line:
        // let valueline = d3.line()
        //     .x(function (d) {
        //         return (d[0]) + xAxisConfig.rightShift;
        //     })
        //     .y(function (d) {
        //         return yAxisConfig.linearScale(d[1]) + yAxisConfig.downShift;
        //     });

        svg.select("g#lines")
            .selectAll("path")
            .data([points])
            .join("path")
            .attr("d", d => line(d))
            .attr("stroke", "#3646f5")
            .attr("stroke-width", 1.5)
            .attr("fill", "#FFFFFF");
    }

    /**
     * Adds blank default "g" elements to the SVG so that we can reuse them by
     * selecting them by their ids at a later time, during rerender().
     */
    let setup = () => {
        let svg = d3.select(svgRef.current);
        svg.append("g").attr("id", "xAxis");
        svg.append("g").attr("id", "yAxis");
        svg.append("g").attr("id", "scatterPlot");
        svg.append("g").attr("id", "lines");
        svg.append("text").attr("id", "marker");
        svg.append("text").attr("id", "xAxisLabel")
        svg.append("text").attr("id", "yAxisLabel")
    };

    let rerender = () => {
        let svg = d3.select(svgRef.current);
        svg.attr("width", svgWidth);
        svg.attr("height", svgHeight);
        setupXAxis(svg, "Return Period");
        setupYAxis(svg, "Return Level");
        plotScatterPlot(svg, data);

        var fakeLinePoints = [[0, 0], [50, 50], [75,100], [80, 150], [90, 250]];
        plotSolidLine(svg, fakeLinePoints);
    }

    useEffect(setup);
    useEffect(rerender);

    return (
        <div>
            <svg ref={svgRef}/>
        </div>
    );
}