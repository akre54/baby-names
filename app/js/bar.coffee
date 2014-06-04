d3 = require "d3"
namesCsv = require "../assets/names.csv"
require "../css/bar.css"

margin = top: 0, right: 20, bottom: 30, left: 40
width = 960 - margin.left - margin.right
height = 500 - margin.top - margin.bottom

formatPercent = d3.format ".0%"

x = d3.scale.ordinal()
    .rangeRoundBands [0, width], .1

y = d3.scale.linear()
    .range [height, 0]

xAxis = d3.svg.axis()
    .scale x
    .orient "bottom"

yAxis = d3.svg.axis()
    .scale y
    .orient "left"
    .ticks 10, "%"

svg = d3.select(".chart").append "svg"
    .attr "width", width + margin.left + margin.right
    .attr "height", height + margin.top + margin.bottom
  .append "g"
    .attr "transform", "translate(#{margin.left},#{margin.top})"

yMax = 0
interval = null
alphabet = String.fromCharCode.apply(null, [65..90]).split ""

findByYear = (year) ->
  result = null
  names.some (value, index, list) ->
    if value.year is year
      result = value
      true
  result.letters

names = d3.csv.parse namesCsv, (row) ->
  row.year = +row.year
  row.letters = for letter in alphabet
    freq = Math.round(+row[letter]) / 100
    yMax = freq if freq > yMax
    { letter, freq }
  row

x.domain alphabet
y.domain [0, yMax]

[{year: initialYear}, ..., {year: finalYear}] = names
currentYear = initialYear

sliderChange = ->
  return if currentYear is +@value
  pause()
  currentYear = +@value
  updateChart()

yearBox = d3.select(".chart").append "h2"
  .attr "class", "current-year"
playPause = d3.select(".chart").append "button"
  .attr "class", "play-pause"
  .on "click", ->
    if interval then pause() else play()
slider = d3.select(".chart").append "input"
  .attr "type", "range"
  .attr "class", "slider"
  .attr "min", initialYear
  .attr "max", finalYear
  .on "change", sliderChange
  .on "click", sliderChange
  .on "mousemove", sliderChange

svg.append "g"
    .attr "class", "x axis"
    .attr "transform", "translate(0,#{height})"
    .call xAxis

svg.append "g"
    .attr "class", "y axis"
    .call yAxis


updateChart = ->
  pause() if currentYear > finalYear

  slider[0][0].value = currentYear
  yearBox.text currentYear

  data = findByYear currentYear

  bars = svg.selectAll ".bar"
      .data data
  bars.enter().append "rect"
      .attr "class", "bar"
      .attr "x", (d) -> x d.letter
      .attr "width", x.rangeBand()
  bars
    .transition()
    .duration 200
    .ease "quad"
      .attr "height", (d) -> height - y d.freq
      .attr "y", (d) -> y d.freq

  labels = svg.selectAll ".label"
    .data data

  labels.enter().append "text"
      .attr "class", "label"
      .attr "x", (d) -> x d.letter

  labels.transition()
      .duration 200
      .ease "quad"
        .attr "y", (d) -> y(d.freq) - 10
        .text (d) -> formatPercent d.freq

  labels.exit()

pause = ->
  playPause.text "Play"
  clearInterval interval
  interval = null

play = ->
  currentYear = initialYear if currentYear > finalYear
  playPause.text "Pause"
  startInterval()

startInterval = ->
  interval = setInterval ->
    pause() if currentYear is finalYear
    return unless interval
    currentYear++
    updateChart()
  , 250

play()