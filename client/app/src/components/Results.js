import React, {useEffect, useState} from 'react';
import * as d3 from 'd3';

export default function Results() {

    var svgRef = React.createRef();
    
    let setup = () => {
        let svg = d3.select(svgRef.current);
        svg.append("g").attr("id", "xAxis");
        svg.append("g").attr("id", "yAxis");
		svg.append("g").attr("id", "lines")
            .attr("fill", "none")
            .attr("stroke", "steelblue")
            .attr("stroke-width", 1.5)
            .attr("stroke-linejoin", "round")
            .attr("stroke-linecap", "round");
        svg.append("text").attr("id", "marker");
        svg.append("text").attr("id", "xAxisLabel")
            .text("X AXIS");
        svg.append("text").attr("id", "yAxisLabel")
            .text("Y AXIS");
    };

    let rerender = () => {
        var data = [[90, 20], [20, 100], [66, 44], [53, 80], [24, 182], [80, 72], [10, 76], [33, 150], [100, 15]];

        var margin = {
            top: 20,
            right: 20,
            bottom: 30,
            left: 40
        }
        var width = 700 - margin.left - margin.right;
        var height = 500 - margin.top - margin.bottom;
        
        let svg = d3.select(svgRef.current);
        svg.attr("viewBox", [0, 0, 1920, 1080]);

        var x = d3.scaleLinear().range([0, width]);
        var y = d3.scaleLinear().range([height, 0]);

        // Scale the range of the data
        x.domain(d3.extent(data, function (d) {
            return d[0];
        }));
        y.domain([0, d3.max(data, function (d) {
            return d[1];
        })]);

        let xAxis = g => g
            .attr("transform", `translate(0,${height - margin.bottom})`)
            .call(d3.axisBottom(x).ticks(width / 80).tickSizeOuter(0))

        let yAxis = g => g
            .attr("transform", `translate(${margin.left}, 0)`)
            .call(d3.axisLeft(y).ticks(height / 40))

        // Title
        svg.append('text')
            .attr('x', width/2 + 100)
            .attr('y', 100)
            .attr('text-anchor', 'middle')
            .style('font-family', 'Helvetica')
            .style('font-size', 20)
            .text('Scatter Plot');
        
        // X label
        svg.append('text')
            .attr('x', width/2 + 100)
            .attr('y', height - 15 + 150)
            .attr('text-anchor', 'middle')
            .style('font-family', 'Helvetica')
            .style('font-size', 12)
            .text('Independent');
        
        // Y label
        svg.append('text')
            .attr('text-anchor', 'middle')
            .attr('transform', 'translate(60,' + height + ')rotate(-90)')
            .style('font-family', 'Helvetica')
            .style('font-size', 12)
            .text('Dependent');

        svg.append('g')
            .selectAll("dot")
            .data(data)
            .enter()
            .append("circle")
            .attr("cx", function (d) { return x(d[0]); } )
            .attr("cy", function (d) { return y(d[1]); } )
            .attr("r", 2)
            .attr("transform", "translate(" + 100 + "," + 100 + ")")
            .style("fill", "#CC0000");

    }

    useEffect(setup);
    useEffect(rerender);

    return (
        <div>
            <svg ref={svgRef}></svg>
        </div>
    );
}