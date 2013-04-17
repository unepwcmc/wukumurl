window.WukumUrl ||= {}
window.WukumUrl.Charters ||= {}
window.WukumUrl.Charters.barChart ||= {}


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
  [ [{id:, val:}, {id:, val:}], ...]
 This is a nested array. The outer array is a list of chart groups.
 Note: chart groups with length > 1 have not yet been tested.
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
    x0Scale.rangeRoundBands([0, _innerWidth()], .2) # args: [min, max], padding
    yScale.range([_innerHeight(), 0])

    selection.each (data, i) ->

      # Data input domains
      x0Scale.domain data.map (d) -> d.name
      yScale.domain [ 0, d3.max data, (d) -> d.max ]
  
      svg = d3.select(this)
      # Update the outer dimensions.
      svg.attr("width", _outerWidth()).attr("height", _outerHeight())

      chart_group = svg.selectAll("g.chart_group").data(data)
      chart_group.enter()
        .append("g")
        .attr("class", "chart_group")
        #.attr("x", (d) -> x0Scale d.name)
        .attr("transform", (d) -> "translate(" + x0Scale(d.name) + ",0)")
        .attr("width", (d) -> x0Scale(d.name) )

      values = data.values
      chart_group.each (data, i) ->
        x1Scale.rangeRoundBands([0, _innerWidth() / data.values.length], .1)
        x1Scale.domain data.values.map (d) -> d.name
        bar = d3.select(@).selectAll('.bar')
          .data (d) -> d.values
        bar.enter()
          .append("rect")
          .attr("class", "bar")
          .attr("x", (d) -> x1Scale d.name)
          .attr("width", 0)
          .attr("y", (d) -> _innerHeight() )
          .attr "height", (d) -> 0
        bar.exit().remove()
        bar.transition()
          .duration(500)
          .attr("x", (d) -> x1Scale d.name)
          .attr("width", x1Scale.rangeBand())
          .attr("y", (d) -> yScale(d.val) )
          .attr "height", (d) -> 
            console.log 'sssssssssss', d
            _innerHeight() - yScale(d.val)



      chart_group.exit().remove()  
        #.each (data, i) ->
        #  console.log @, data, i
        #  g = d3.select(@).attr "class", "chart_group"

      ## Otherwise, create the skeletal chart.
      #gEnter = _createSkeletalChart svg
      #
      ## Update the outer dimensions.
      #svg.attr("width", _outerWidth()).attr("height", _outerHeight)
      #
      ## Update the inner dimensions.
      #g = _updateInnerDimensions svg.select("g")
      #
      ## Update the barchart.
      #gBar = _updateBarchart g.select(".barchart")
      #
      ## Update the x-axis.
      #gX = _updateXAxis g.select(".x.axis")
      #  
      ## Update the y-axis.
      #gY = _updateYAxis g.select(".y.axis")

         
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