window.WukumUrl ||= {}
window.WukumUrl.Charters ||= {}
#window.WukumUrl.Charters.barChart ||= {}


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
  # Select the parent element where to render the chart
  selection = d3.select("#chart")
  # Attach to the selection the data
  data = [{"id":"a43d","val":"3.83"},{"id":"4e9a","val":"2.67"}] 
  selection.data([data])
  # Render the chart!
  selection.call barchart
 
 About the data:
  It expects a data structure in the form:
  [
    [
      {
        "max":88,
        "values":[
          {
            "name":"entry count",
            "val":88
          },
          {
            "name":"exit count",
            "val":23
          }
        ],
        "name":"a43d"
      },
      {
        "max":16,
        "values":[
          {
            "name":"entry count",
            "val":16
          },
          {
            "name":"exit count",
            "val":6
          }
        ],
        "name":"4e9a"
      }
    ]
  ]
###
WukumUrl.Charters.barChart = ->

  margin =
   top: 10
   right: 20
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
  #colours = ["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]

  color = d3.scale.linear()
    .domain([0, 1])
    .range(["#060F00", "#E3F5D7"]);


  _outerWidth = ->
    width + margin.left + margin.right

  _innerWidth = ->
    width - margin.left - margin.right

  _outerHeight = ->
    height + margin.left + margin.right

  _innerHeight = ->
    height - margin.left - margin.right

  _createSkeletalChart = (svg) ->
    gEnter = svg.enter().append("svg").append("g")
    gEnter.append("g").attr "class", "barchart"
    gEnter.append("g").attr "class", "x axis"
    gEnter.append("g").attr "class", "y axis"
    gEnter

  _updateXAxis = (selection) ->
    selection.attr("transform", "translate(0," + _innerHeight() + ")")
      .call xAxis

  _updateYAxis = (selection) ->
    selection.call(yAxis)
      #.append("text")
      #.attr("transform", "rotate(-90)").attr("y", 12)
      #.attr("dy", ".71em").style("text-anchor", "end")
      #.text "Ratio"

  # Translates the chart g container to leave space to the axis.
  # Note: the axis dimensions are being added to the outer_width, they are
  # not contained within, that is why we need to move the g container. 
  _updateInnerDimensions = (selection) ->
    selection
      # translate(x, y) -> move right x pixels, move down y pixels.
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  # For understanding enter-exit:
  # http://mbostock.github.io/d3/tutorial/circle.html
  _updateBarchart = (selection) ->
    selection.each (d, i) ->
      bar = d3.select(@).selectAll(".bar").data(d)
      bar.enter()
        .append("rect")
        .attr("class", "bar")
        .attr("x", (d) -> x0Scale d.id)
        .attr("width", 0)
        .attr("y", (d) -> _innerHeight() )
        .attr "height", (d) -> 0
      bar.exit().remove()
      bar.transition()
        .duration(500)
        .attr("x", (d) -> x0Scale d.id)
        .attr("width", x0Scale.rangeBand())
        .attr("y", (d) -> yScale(d.val) )
        .attr "height", (d) -> _innerHeight() - yScale(d.val)
    selection


  ###
   Public Interface
  ###

  chart = (selection) ->

    # Scale ranges need to be called here and not outside of the chart 
    # function, because they need to be updated on every new selection.
    # !! Why using ouerWidth() ??
    # X0 refers to the outer group.
    x0Scale.rangeRoundBands([0, _outerWidth()], .2) # args: [min, max], padding
    yScale.range([_innerHeight(), 0])

    # On the first `each` we are in the outside group.
    selection.each (data, i) ->

      # Data input domains
      x0Scale.domain data.map (d) -> d.name
      yScale.domain [ 0, d3.max data, (d) -> d.max ]
  
      svg = d3.select(this)
      # Set the outer dimensions.
      svg.attr("width", _outerWidth()).attr("height", _outerHeight())
      # Append a g element exclusively for the bars.
      chart_container = svg.append("g")
        # And lets translate it right (in order to leave space for the axis).
        #.attr("transform", (d) -> "translate(" + margin.left + ",0)")

      # Select all the chart groups, if existent.
      chart_group = chart_container.selectAll("g.chart_group").data(data)
      # Otherwise, create the skeletal chart groups.
      chart_group.enter()
        .append("g")
        .attr("class", "chart_group")
        .attr("transform", (d) -> 
          console.log _innerWidth(), x0Scale(d.name)
          "translate(" + x0Scale(d.name) + ",0)")
        #.attr("width", (d) -> x0Scale(d.name) )

      # iterating over every chart group, in order to draw the single bars.
      chart_group.each (inner_data, i) ->
        # X1 refers to the inner group.
        x1Scale.rangeRoundBands([0, _innerWidth() / data.length], .1)
        x1Scale.domain inner_data.values.map (d) -> d.name
        bar = d3.select(@).selectAll('.bar')
          .data (d) -> d.values
        bar.enter()
          .append("rect")
          .attr("class", "bar")
          .attr("x", (d) -> x1Scale d.name)
          .attr("width", 0)
          .attr("y", (d) -> _innerHeight() )
          .attr("height", (d) -> 0)
          .style "fill", (d, i) -> 
            console.log (i+1)/inner_data.values.length
            color( (i+1)/inner_data.values.length ) 
        bar.exit().remove()
        bar.transition()
          .duration(500)
          .attr("x", (d) -> x1Scale d.name)
          .attr("width", x1Scale.rangeBand())
          .attr("y", (d) -> yScale(d.val) )
          .attr "height", (d) -> 
            #console.log 'sssssssssss', d
            _innerHeight() - yScale(d.val)

      chart_group.exit().remove()  
        
         

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

  chart