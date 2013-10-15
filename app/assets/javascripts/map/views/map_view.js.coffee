window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.Map extends Backbone.View

  el: "#map-canvas"

  initialize: (@options) ->
    # Default collection
    @collection = @options.countriesCollection
    @prevCollection = @prevCollectionName = null
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
    # TODO: move this into a function that can better handle the data changing 
    # over time. 
    @categories =
      countriesCollection: [
          max_val: 10
          size: 8
          font_size: 15
        ,
          max_val: 99
          size: 16
          font_size: 20
        ,
          max_val: Infinity
          size: 28
          font_size: 24
        ]
      citiesCollection: [
          max_val: 10
          size: 12
          font_size: 16
        ,
          max_val: 49
          size: 16
          font_size: 18
        ,
          max_val: 99
          size: 20
          font_size: 22
        ,
          max_val: Infinity
          size: 24
          font_size: 25
        ]
      locationsCollection: [
          max_val: 5
          size: 4
          font_size: 15
        ,
          max_val: 9
          size: 8
          font_size: 16
        ,
          max_val: 20
          size: 14
          font_size: 18
        ,
          max_val: 40
          size: 18
          font_size: 22
        ,
          max_val: Infinity
          size: 24
          font_size: 26
        ]
    # Caching the values for the etCat function
    @getCatMem = @getCat()
    

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

  getCat: ->
    _.memoize (value) =>
      level = @categories[@collectionName]
      unless level
        throw new Error "getCat: cannot find level"
      _.find level, (v, i) -> value < v.max_val

  categorizeValue: (value) ->
    cat = @getCatMem value
    cat.size

  getFontSize: (value) ->
    cat = @getCatMem value
    cat.font_size

  # Calculate the radius as a value-area proportion.
  calculateRadius: ->
    _.memoize (value) =>
      if @options.use_categories
        return @categorizeValue value
      maxValue = @max
      maxSize = 30
      Math.sqrt(value / maxValue) * maxSize

  centreText: (value) ->
    if value > 999
      return 28
    if value > 99
      return 20
    if value > 9
      return 13
    4
    
  setCollection: (collectionName) ->
    @prevCollection = @collection
    @collection = @options[collectionName]
    @max = @collection.getMaxVal()
    {collection: @collection, prevCollection: @prevCollection, max: @max}

  setCollectionName: (zoom) =>
    @prevCollectionName = @collectionName
    @collectionName = @zoomSteps[zoom]
    @mediator.trigger "Views:Map:collectionNameChange", @collectionName
    @collectionName

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
    @drawSvg data.data, no # no, do not update svg:text

  # Derived from: https://gist.github.com/mbostock/899711
  initOverlays: ->
    self = this
    # Remove loading gif
    $(".ajax-loader").hide()
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

  # The function is partially applied with `layer` and `self` arguments.
  # `layer` is the div element that wraps all the svg elements that 
  #  appear on the map.
  # `self` is a reference to the instance (this) of WukumUrl.Map.Views.Map.
  drawSvg: (layer, self, data) ->
    rFactor = 1
    cR = self.calculateRadius()

    transform = (d) ->
      r = cR(d.size * rFactor)
      d = new google.maps.LatLng(d.lat, d.lng)
      d = projection.fromLatLngToDivPixel(d)
      d3.select(this)
        .style("left", (d.x - r) + "px")
        .style("top", (d.y - r) + "px")
        .style("height", "#{r*2}px")
        .style("width", "#{r*2}px")
        .style("padding", "2px")

    transformTxt = (d) ->
      r = cR(d.size * rFactor)
      d3.select(this)
        .attr("x", (d) -> r - self.centreText(d.size))
        .attr("y", (d) -> r )

    transformCircle = (d) ->
      r = cR(d.size * rFactor)
      d3.select(this)
        .attr("r", (d) -> r )
        .attr("cx", (d) -> r )
        .attr("cy", (d) -> r )

    addEventListeners = (d) ->
      google.maps.event.addDomListener this, 'click', (e) ->
        self.mediator.trigger "Views:Map:selectLocation", d
        self.killEvent = yes
    
    projection = @getProjection()

    marker = layer.selectAll("svg")
      .data(data, (d) -> d.uique_id)
      .each(transform) # update existing markers
      .attr("class", (d) -> d.state)

    enter = marker.enter().append("svg:svg")
      .each(transform)
      .attr("class", (d) -> d.state)

    # Lets position the text first (under the circle), so it does not interfere
    # with the click events. Only works because our circles are semi-transparent.
    txt = enter.append("svg:text")
      .each(transformTxt)
      .attr("dy", ".31em")
      .text((d) -> d.size)
      .style("font-size", (d) -> 
        s = self.getFontSize d.size
        "#{s}px"
      )

    circle = enter.append("svg:circle")
      .each(addEventListeners)
      .each(transformCircle)

    exit = marker.exit()
      #.each(removeEventListener) # TODO?
      .remove()

   


    