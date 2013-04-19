window.WukumUrl ||= {}
window.WukumUrl.Charters ||= {}

###
 Easy to use barchart generator.

 Inspired by:
 -- http://bost.ocks.org/mike/chart/
 
 Usage example:
  # Call the main charter function. This returns a closure.
  chart = WukumUrl.Charters.barChart()
  # Customize the chart:
  chart.width 500
  chart.height 600
  chart.events ["onHover"]
  # Select the parent element where to render the chart
  selection = d3.select("#chart")
  # Attach to the selection the data
  data = [...] 
  selection.data [data]
  # Render the chart!
  selection.call barchart
 
 About the data:
  It expects a data structure in the form:
  [
    [
      {
        "name":"a43d",
        "max":88,
        "values":[
          {
            "name":"entry count",
            "val":88,
            ...
          },
          {
            "name":"exit count",
            "val":23,
            ...
          }
        ]
      },
      {  
        "name":"4e9a",
        "max":16,
        "values":[
          {
            "name":"entry count",
            "val":16,
            ...
          },
          {
            "name":"exit count",
            "val":6,
            ...
          }
        ]
      }
    ]
  ]
###
WukumUrl.Charters.barChart = ->

  margin =
   top: 20
   right: 120
   bottom: 20
   left: 30
  width = 560
  height = 500
  format = d3.format(".0")
  x0Scale = d3.scale.ordinal()
  x1Scale = d3.scale.ordinal()
  yScale = d3.scale.linear()
  xAxis = d3.svg.axis().scale(x0Scale).orient("bottom")
  yAxis = d3.svg.axis().scale(yScale).orient("left").tickFormat(format)
  # TODO: handle colours better.
  color = d3.scale.linear()
    .range(["#15534C", "#E2E062"])
  #color = d3.scale.category10()
  events = ["onClick"]


  _outerWidth = ->
    width + margin.left + margin.right

  _innerWidth = ->
    width - margin.left - margin.right

  _outerHeight = ->
    height + margin.left + margin.right

  _innerHeight = ->
    height - margin.left - margin.right

  # TODO: need to hook in the exits!
  _drawLegend = (selection, data) ->
    outer_legend = selection.selectAll("g.outer_legend")
      .data([data])
    .enter().append("g")
      .attr("class", "outer_legend")
      .attr("transform", 
        "translate(" + (margin.left + margin.right) + "," + margin.top + ")")
    legend = outer_legend.selectAll("g.legend")
        .data(data.slice())
      .enter().append("g")
        .attr("class", "legend")
        .attr("transform", (d, i) -> "translate(0," + i * 20 + ")")
    legend.append("rect")
        .attr("x", width - 18)
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", (d, i) -> color(i+1) )
    txt = legend.append("text")
        .attr("x", width - 24)
        .attr("y", 9)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text((d) -> d)
        # Used for future selection and interaction:
        .attr("id", (d) -> "l_#{d}" )
    # Custom events:
    if _.find(events, (evt) -> evt == "onHover") == "onHover"
      dispatch = WukumUrl.Charters.barChart.dispatch
      txt.on "mouseover", (d, i) -> dispatch.onHover.apply this, [d, i, yes]
      txt.on "mouseout", (d, i) -> dispatch.onHover.apply this, [d, i]


  ###
    User interactions section
    See: https://github.com/mbostock/d3/wiki/Internals#wiki-d3_dispatch
  ###

  # Highlights the selected item in the legend
  updateLegend = (d, i, entering) ->
    name = d?.name || d
    item = d3.select("#l_#{name}")
    if entering
      item.attr("class", "selected")
    else
      item.attr("class", "")

  # Highlights the selected bar(s)
  updateBars = (d, i, entering) ->
    name = d.name || d
    items = d3.selectAll(".b_#{name}")
    original_class_values = items.attr("class").replace /selected/, ""
    if entering
      items.attr("class", "#{original_class_values} selected")
    else
      items.attr("class", original_class_values)


  ###
   Public Interface
  ###

  #TODO: this big chart function needs some careful refactoring.
  chart = (selection) ->

    # Setting and exposing custom events.
    WukumUrl.Charters.barChart.dispatch = d3.dispatch.call this, events
    dispatch = WukumUrl.Charters.barChart.dispatch
    _.each events, (evt) ->
      dispatch.on "#{evt}.legend", updateLegend
      dispatch.on "#{evt}.onHover.bar", updateBars

    # Scale ranges need to be called here and not outside of the chart 
    # function, because they need to be updated on every new selection.
    # !! Why using ouerWidth() ??
    # X0 refers to the outer group.
    x0Scale.rangeRoundBands([0, _outerWidth() - margin.right], .2) # args: [min, max], padding
    yScale.range([_innerHeight(), 0])

    # This is the first outer selection.
    # Usually the 'selection` length will be equal to one.
    selection.each (data, i) ->

      bar_names = _.map data[0].values, (d) -> d.name

      # Data input domains
      x0Scale.domain data.map (d) -> d.name
      yScale.domain [ 0, d3.max data, (d) -> d.max ]
      color.domain([0, data[0].values.length])

      # Select the svg element, if it exists.
      svg = d3.select(this).selectAll("svg").data([data])

      # Otherwise, create the skeletal chart.
      gEnter = svg.enter().append("svg").append("g")
      #gEnter.append("g").attr "class", "chart_group"
      gEnter.append("g").attr "class", "x axis"
      gEnter.append("g").attr "class", "y axis"

      # Set the outer dimensions.
      svg.attr("width", _outerWidth()).attr("height", height)

      # translate(x, y) -> move right x pixels, move down y pixels.
      g = svg.select("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      # Update the x-axis.
      g.select(".x.axis")
        .attr("transform", 
          "translate(0," + (_innerHeight() + margin.bottom) + ")")
        .call(xAxis)

      # Update the y-axis.
      g.select(".y.axis")
        .call(yAxis)
        .attr("transform", (d) -> "translate(" + margin.left + ",0)")

      # Select all the chart groups, if existent.
      chart_group = g.selectAll("g.chart_group").data(data)
      # Otherwise, create the skeletal chart groups.
      chart_group.enter()
        .append("g")
        .attr("class", "chart_group")
        .attr("transform", (d) -> "translate(" + x0Scale(d.name) + ",0)")

      # iterating over every chart group, in order to draw the single bars.
      chart_group.each (inner_data, i) ->
        # X1 refers to the inner group.
        x1Scale.rangeRoundBands([0, _innerWidth() / data.length], .1)
        x1Scale.domain inner_data.values.map (d) -> d.name
        bar = d3.select(@).selectAll('.bar')
          .data (d) -> d.values
        bar.enter()
          .append("rect")
          .attr("class", (d) -> "bar b_#{d.name}")
          .attr("x", (d) -> x1Scale d.name)
          .attr("width", 0)
          .attr("y", (d) -> _innerHeight() )
          .attr("height", (d) -> 0)
          .style "fill", (d, i) -> 
            color(i+1)
        bar.exit().remove()
        bar.transition()
          .duration(500)
          .attr("x", (d) -> x1Scale d.name)
          .attr("width", x1Scale.rangeBand())
          .attr("y", (d) -> yScale(d.val) )
          .attr "height", (d) -> _innerHeight() - yScale(d.val)
        
        if _.find(events, (evt) -> evt == "onHover") == "onHover"
          bar.on "mouseover", (d, i) -> 
            dispatch.onHover.apply this, [d, i, yes]
          bar.on "mouseout", (d, i) -> dispatch.onHover.apply this, [d, i]

      chart_group.exit().remove()

      _drawLegend svg, bar_names
 

  # IMPORTANT: when customizing the chart, margin MUST be called before
  # height, because height depends on the margin being set.
  chart.margin = (_) ->
    return margin  unless arguments.length
    margin = _
    chart

  chart.width = (_) ->
    return width  unless arguments.length
    width = _
    chart

  chart.height = (_) ->
    return height  unless arguments.length
    height = _ - margin.top - margin.bottom
    chart

  chart.x0Scale = (_) ->
    return x0Scale  unless arguments.length
    x0Scale = _
    chart

  chart.yScale = (_) ->
    return yScale  unless arguments.length
    yScale = _
    chart

  chart.events = (_) ->
    return events  unless arguments.length
    events = _
    chart

  chart