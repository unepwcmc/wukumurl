window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.Map extends Backbone.View

  el: "#map-canvas"

  initialize: (@options) ->
    # Default collection
    @collection = @options.citiesCollection
    @prevCollection = null
    @mediator = options.mediator
    @listenTo @collection, "reset", @initOverlays
    #@listenTo @collection, "change", @filterData
    @listenTo @mediator, "Views:Map:selectLocation", @updateSVG
    @listenTo @mediator, "Views:Map:collectionChange", @onCollectionChange
    @listenTo @mediator, "Views:Map:zoomChange", @onZoomChange
    # Not ideal, we are setting a class-global data object here.
    # This because of the `overlay.draw` method, used from the Google Maps API.
    # On map pan and zoom this method is called and it expects a `data` value
    # to be in scope.
    @data = null
    @zoomSteps = 
       0:  "citiesCollection"
       1:  "citiesCollection"
       2:  "citiesCollection"
       3:  "citiesCollection"
       4:  "citiesCollection"
       5:  "citiesCollection"
       6:  "citiesCollection"
       7:  "citiesCollection"
       8:  "citiesCollection"
       9:  "citiesCollection"
       10: "citiesCollection"
       11: "locationsCollection"
       12: "locationsCollection"
       13: "locationsCollection"
       14: "locationsCollection"
       15: "locationsCollection"
       16: "locationsCollection"
       17: "locationsCollection"
       18: "locationsCollection"


  render: ->
    if @options.map_options
      @map = new google.maps.Map @el, @options.map_options
      @setMapEventListeners @map

  #filterData: (st) ->
  #  #console.log "Views.Map:filterData", st
  #  @data = @collection.parseDataForMap()
  #  _.each @data, (data, state) => @drawSvg data, state

  setMapEventListeners: (map) ->
    self = this
    google.maps.event.addListener map, 'zoom_changed', ->
      zoom = map.getZoom()
      self.mediator.trigger "Views:Map:zoomChange", zoom

  onCollectionChange: (collection) =>
    # Resetting the prevCollection state so when zooming back to the 
    # prevCollection we do not find selected circles on the map.
    @prevCollection.resetState()
    @data = @collection.sortDataForMap @collection.parseDataForMap()
    @drawSvg @data

  onZoomChange: (zoom) =>
    #console.log "onZoomChange", zoom, @zoomSteps[zoom]
    newCollectionName = @zoomSteps[zoom]
    if newCollectionName
      @prevCollection = @collection
      @collection = @options[newCollectionName]
    else 
      throw new Error "Wrong collection name! #{zoom}"
    if @collection != @prevCollection
      @mediator.trigger "Views:Map:collectionChange", @collection

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
    @mediator.trigger "Views:Map:dataUpdated", data.d, @collection
    @drawSvg data.data

  # Derived from: https://gist.github.com/mbostock/899711
  initOverlays: ->
    #console.log "initOverlays"
    self = this
    @data = @collection.sortDataForMap @collection.parseDataForMap()
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
        .style("padding", "2px")


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

    marker.append("svg:text")
    .attr("x", (d) -> view.calculateRadius(d.size * rFactor) - 10)
    .attr("y", (d) -> view.calculateRadius(d.size * rFactor) )
    .attr("dy", ".31em").text (d) ->
      if view.calculateRadius(d.size * rFactor) > 10
        d.size
    