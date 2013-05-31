window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.Map extends Backbone.View

  el: "#map-canvas"

  initialize: (@options) ->
    @collection = @options.shortUrlsCollection
    @mediator = options.mediator
    @listenTo @collection, "reset", @initOverlays
    #@listenTo @collection, "change", @filterData
    @listenTo @mediator, "Views:Map:selectLocation", @updateSVG
    # Not ideal, we are setting a class-global data object here.
    # This because of the `overlay.draw` method, used from the Google Maps API.
    # On map pan and zoom this method is called and it expects a `data` value
    # to be in scope.
    @data = null


  render: ->
    if @options.map_options
      @map = new google.maps.Map @el, @options.map_options

  #filterData: (st) ->
  #  #console.log "Views.Map:filterData", st
  #  @data = @collection.parseDataForMap()
  #  _.each @data, (data, state) => @drawSvg data, state

  toggleState: (id) ->
    data = {}
    _.each @data, (d, idx) =>
      if d.location_id == id
        state = d.state
        newState = @collection.invertedState state
        @collection.get(id).set "state", newState
        @data[idx].state = newState
        data.d = @data[idx]
      else 
        @data[idx].state = "inactive"
        #console.log state, newState, @data[idx], idx
    data.data = @data
    data

  calculateRadius: (value) ->
    maxValue = 309
    maxSize = 40
    Math.sqrt(value / maxValue) * maxSize

  updateSVG: (d) =>
    data = @toggleState d.location_id
    @mediator.trigger "Views:Map:dataUpdated", data.d
    @drawSvg data.data

  # Derived from: https://gist.github.com/mbostock/899711
  initOverlays: ->
    #console.log "initOverlays"
    self = this
    @data = @collection.parseDataForMap()
    # Create an overlay.
    overlay = new google.maps.OverlayView()

    # Add the container when the overlay is added to the map.
    overlay.onAdd = ->
      layer = d3.select(@getPanes().overlayMouseTarget)
        .append("div").attr("class", "locations")
      self.drawSvg = _.bind self.drawSvg, @, layer, self

    overlay.draw = ->
      #console.log "overlay.draw"
      self.drawSvg self.data

    # Bind our overlay to the map…
    overlay.setMap @map


  # The function is partially applied with the `layer` argument
  # within the `overlay.onAdd` method.
  drawSvg: (layer, view, data) ->
    #console.log "drawSvg", data
    rFactor = 1
    transform = (d) ->
      #console.log d #"transform", d, d3.select(this)
      r = view.calculateRadius(d.size * rFactor)
      #padding = r * 1.1
      d = new google.maps.LatLng(d.lat, d.lng)
      d = projection.fromLatLngToDivPixel(d)
      #console.log state
      d3.select(this)
        .style("left", (d.x - r) + "px")
        .style("top", (d.y - r) + "px")
        .style("height", r*2)
        .style("width", r*2)

    addEventListener = (d) ->
      google.maps.event.addDomListener this, 'click', (e) ->
        #view.toggleState d.location_id
        #console.log "addEventListener", d
        view.mediator.trigger "Views:Map:selectLocation", d
    
    projection = @getProjection()
    #padding = 10
    marker = layer.selectAll("svg")
      #.data(data, (d) -> d.location_id)
      .data(data)
      .each(transform) # update existing markers
      .attr("class", (d) -> d.state)
    enter = marker.enter().append("svg:svg")
      .each(transform)
      .attr("class", "marker")
      .attr("class", (d) -> d.state)
      .append("svg:circle")
      .each(addEventListener)
      .attr("r", (d) ->
        #console.log d
        r = view.calculateRadius(d.size * rFactor)
        r
      )
      .attr("cx", (d) ->
        r = view.calculateRadius(d.size * rFactor)
        r# * 1.1
      )
      .attr("cy", (d) ->
        r = view.calculateRadius(d.size * rFactor)
        r# * 1.1
      )
      #.attr("class", (d) -> 
      #  console.log d.state
      #  d.state)

      #.attr("r", 6.5).attr("cx", padding).attr("cy", padding)
      #.attr "class", (d) -> d.state
      #
    exit = marker.exit()
      #.each(removeEventListener)
      .remove()

    #marker.append("svg:text")
    #.attr("x", padding + 7)
    #.attr("y", padding)
    #.attr("dy", ".31em").text (d) ->
    #  d.value.visit_id
    