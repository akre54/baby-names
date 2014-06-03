d3 = require "d3"
namesCsv = require "../assets/names.csv"
require "../css/parfait.css"


margin = {top: 20, right: 20, bottom: 30, left: 50}
width = 960 - margin.left - margin.right
height = 500 - margin.top - margin.bottom

parseDate = d3.time.format("%Y").parse

x = d3.time.scale()
    .range [0, width]

y = d3.scale.linear()
    .range [height, 0]

colorrange = ["#045A8D", "#2B8CBE", "#74A9CF", "#A6BDDB", "#D0D1E6", "#F1EEF6"]
strokecolor = colorrange[0]

color = d3.scale.ordinal()
  .range colorrange

xAxis = d3.svg.axis()
    .scale x
    .orient "bottom"

yAxis = d3.svg.axis()
    .scale y
    .orient "left"
    .ticks 10, "%"

area = d3.svg.area()
    .interpolate "cardinal"
    .x (d) -> x d.date
    .y0 (d) -> y d.y0
    .y1 (d) -> y d.y0 + d.y

stack = d3.layout.stack()
    .values (d) -> d.values

svg = d3.select(".chart").append "svg"
    .attr "width", width + margin.left + margin.right
    .attr "height", height + margin.top + margin.bottom
  .append "g"
    .attr "transform", "translate(#{margin.left},#{margin.top})"

data = d3.csv.parse namesCsv

color.domain String.fromCharCode.apply null, [65..90]

d.date = parseDate d.year for d in data

letters = stack color.domain().map (letter) ->
  letter: letter
  values: data.map (d) -> date: d.date, y: d[letter] / 100


x.domain d3.extent data, (d) -> d.date

layer = svg.selectAll ".layer"
    .data letters
  .enter().append "g"
    .attr "class", "layer"

layer.append "path"
    .attr "class", "area"
    .attr "d", (d) -> area d.values
    .style "fill", (d) -> color d.letter

svg.append "g"
    .attr "class", "x axis"
    .attr "transform", "translate(0,#{height})"
    .call xAxis

svg.append "g"
    .attr "class", "y axis"
    .call yAxis

findPercent = (vals, year) ->
  result = null
  vals.some (val) ->
    if val.date.getFullYear() is year
      result = Math.floor val.y * 100
      true
  result

svg.selectAll ".layer"
  .attr "opacity", 1
  .on "mouseover", (d, i) ->
    svg.selectAll(".layer").transition()
    .duration 250
    .attr "opacity", (d, j) ->
      if j isnt i then 0.6 else 1

  .on "mousemove", (d, i) ->
    mousepos = d3.mouse this
    mousex = mousepos[0]
    mousey = mousepos[1]
    year = x.invert(mousex).getFullYear()
    percent = findPercent d.values, year

    d3.select this
      .classed "hover", true
      .attr "stroke", strokecolor
      .attr "stroke-width", "0.5px"

    tooltip
      .html "<p>#{percent}%</p>"
      .style "left", mousex + 70
      .style "top", mousey - 30
      .style "visibility", "visible"

  .on "mouseout", (d, i) ->
    svg.selectAll ".layer"
      .transition()
      .duration 250
      .attr "opacity", "1"

    d3.select this
      .classed "hover", false
      .attr "stroke-width", "0px"

    tooltip
      .style "visibility", "hidden"

tooltip = d3.select "body"
  .append "div"
  .attr "class", "tooltip"

vertical = d3.select ".chart"
  .append "div"
  .attr "class", "vertical"

d3.select ".chart"
  .on "mousemove", ->
    mousepos = d3.mouse this
    mousex = mousepos[0] + 5;
    vertical.style "left", "#{mousex}px"
  .on "mouseover", ->
    mousepos = d3.mouse this
    mousex = mousepos[0] + 5;
    vertical.style "left", "#{mousex}px"
