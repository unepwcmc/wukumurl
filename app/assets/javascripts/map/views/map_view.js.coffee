window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.Map extends Backbone.View

  el: "#map-canvas"

  initialize: (@options) ->
    # Default collection
    @collection = @options.countriesCollection
    @prevCollection = null
    @mediator = options.mediator
    @listenTo @collection, "reset", @initOverlays
    #@listenTo @collection, "change", @filterData
    @listenTo @mediator, "Views:Map:selectLocation", @updateSVG
    @listenTo @mediator, "Views:Map:collectionChange", @onCollectionChange
    @listenTo @mediator, "Views:Map:zoomChange", @onZoomChange
    @listenTo @mediator, "Views:Map:click", @onMapClick
    # Workaround to stop event propagation on map click if clicking a 
    # map circle overlay.
    @killEvent = no
    # Not ideal, we are setting a class-global data object here.
    # This because of the `overlay.draw` method, used from the Google Maps API.
    # On map pan and zoom this method is called and it expects a `data` value
    # to be in scope.
    @data = @max = null
    @zoomSteps = 
      0:  "countriesCollection"
      1:  "countriesCollection"
      2:  "countriesCollection"
      3:  "countriesCollection"
      4:  "countriesCollection"
      5:  "countriesCollection"
      6:  "citiesCollection"
      7:  "citiesCollection"
      8:  "citiesCollection"
      9:  "citiesCollection"
      10: "citiesCollection"
      11: "citiesCollection"
      12: "locationsCollection"
      13: "locationsCollection"
      14: "locationsCollection"
      15: "locationsCollection"
      16: "locationsCollection"
      17: "locationsCollection"
      18: "locationsCollection"
    @setCollectionName @options.map_options.zoom
    @categories =
      countriesCollection: [
          max_val: 10
          size: 8
        ,
          max_val: 20
          size: 16
        ,
          max_val: Infinity
          size: 24
        ]
      citiesCollection: [
          max_val: 4
          size: 6
        ,
          max_val: 8
          size: 12
        ,
          max_val: 16
          size: 18
        ,
          max_val: Infinity
          size: 24
        ]
      locationsCollection: [
          max_val: 2
          size: 4
        ,
          max_val: 5
          size: 8
        ,
          max_val: 8
          size: 14
        ,
          max_val: 16
          size: 18
        ,
          max_val: Infinity
          size: 24
        ]
    # Caching the values for the categorizeValue function
    @categorizeValueMem = @categorizeValue()
    

  render: ->
    if @options.map_options
      @map = new google.maps.Map @el, @options.map_options
      @setMapEventListeners @map

  setMapEventListeners: (map) ->
    self = this
    google.maps.event.addListener map, 'zoom_changed', ->
      zoom = map.getZoom()
      self.mediator.trigger "Views:Map:zoomChange", zoom
    google.maps.event.addDomListener map, 'click', (e) ->
      # HACK
      # This click event gets fired even when clicking on the circles, so
      # using setTimeout with killEvent state to handle event propagation.
      window.setTimeout ->
        self.mediator.trigger "Views:Map:click"
        self.killEvent = no
      , 100

  # Toggles state attribute on the @data object, not on the model. If a 
  # non-existent id is passed in, it sets `state:inactive` for all elements.
  toggleState: (id) ->
    data = {}
    _.each @data, (d, idx) =>
      if d.id == id
        state = d.state
        newState = @collection.invertedState state
        @collection.get(id).set "state", newState
        @data[idx].state = newState
        data.d = @data[idx]
      else 
        @data[idx].state = "inactive"
    data.data = @data
    data

  categorizeValue: ->
    _.memoize (value) =>
      level = @categories[@collectionName]
      unless level
        return value
      cat = _.find level, (v, i) -> value < v.max_val
      cat.size

  # Calculate the radius as a value-area proportion.
  calculateRadius: (value) ->
    if @options.use_categories
      return @categorizeValueMem value
    maxValue = @max
    maxSize = 30
    Math.sqrt(value / maxValue) * maxSize

  centreText: (value) ->
    if value > 99
      return 16
    if value > 9
      return 12
    4
    
  setCollection: (collectionName) ->
    @prevCollection = @collection
    @collection = @options[collectionName]
    @max = @collection.getMaxVal()
    {collection: @collection, prevCollection: @prevCollection, max: @max}

  setCollectionName: (zoom) ->
    @collectionName = @zoomSteps[zoom]

  # The collection changes depending on zoom-level.
  onCollectionChange: (collection) =>
    # Resetting the prevCollection state so when zooming back to the 
    # prevCollection we do not find selected circles on the map.
    @prevCollection.resetState()
    @data = @collection.parseDataForMap()
    @drawSvg @data
  
  onZoomChange: (zoom) =>
    newCollectionName = @setCollectionName zoom
    if newCollectionName
      c = @setCollection newCollectionName
    else 
      throw new Error "Wrong collection name! #{zoom}"
    if c.collection != c.prevCollection
      @mediator.trigger "Views:Map:collectionChange", c.collection

  onMapClick: =>
    unless @killEvent
      @updateSVG -999

  updateSVG: (d) =>
    data = @toggleState d.id
    @mediator.trigger "Views:Map:dataUpdated", data.d, @collection
    @drawSvg data.data

  # Derived from: https://gist.github.com/mbostock/899711
  initOverlays: ->
    self = this
    @data = @collection.parseDataForMap()
    @max = @collection.getMaxVal()
    # Create an overlay.
    overlay = new google.maps.OverlayView()

    # Add the container when the overlay is added to the map.
    overlay.onAdd = ->
      layer = d3.select(@getPanes().overlayMouseTarget)
        .append("div").attr("class", "locations")
      self.drawSvg = _.bind self.drawSvg, @, layer, self

    overlay.draw = ->
      self.drawSvg self.data

    # Bind our overlay to the map…
    overlay.setMap @map

  # The function is partially applied with the `layer` argument
  # within the `overlay.onAdd` method.
  drawSvg: (layer, view, data) ->
    rFactor = 1
    transform = (d) ->
      r = view.calculateRadius(d.size * rFactor)
      d = new google.maps.LatLng(d.lat, d.lng)
      d = projection.fromLatLngToDivPixel(d)
      d3.select(this)
        .style("left", (d.x - r) + "px")
        .style("top", (d.y - r) + "px")
        .style("height", r*2)
        .style("width", r*2)
        .style("padding", "2px")

    addEventListeners = (d) ->
      google.maps.event.addDomListener this, 'click', (e) ->
        view.mediator.trigger "Views:Map:selectLocation", d
        view.killEvent = yes
    
    projection = @getProjection()
    marker = layer.selectAll("svg")
      .data(data, (d) -> d.uique_id)
      .each(transform) # update existing markers
      .attr("class", (d) -> d.state)

    enter = marker.enter().append("svg:svg")
      .each(transform)
      .attr("class", (d) -> d.state)
      .append("svg:circle")
      .each(addEventListeners)
      .attr("r", (d) -> view.calculateRadius(d.size * rFactor) )
      .attr("cx", (d) -> view.calculateRadius(d.size * rFactor) )
      .attr("cy", (d) -> view.calculateRadius(d.size * rFactor) )
    exit = marker.exit()
      #.each(removeEventListener) # TODO?
      .remove()

    # TODO: Circle labels need a better implementation.
    marker.insert("svg:text", "circle")
    #marker.append("svg:text")
    .attr("x", (d) ->
      view.calculateRadius(d.size * rFactor) - view.centreText(d.size))
    .attr("y", (d) -> 
      view.calculateRadius(d.size * rFactor) )
    .attr("dy", ".31em").text (d) ->
      if view.calculateRadius(d.size * rFactor) > 14
        #circle = d3.select(this).node().parentNode.firstChild
        d.size


    