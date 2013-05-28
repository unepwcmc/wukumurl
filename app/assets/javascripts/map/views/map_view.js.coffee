window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.Map extends Backbone.View

  el: "#map-canvas"

  initialize: (@options) ->
    @collection = @options.shortUrlsCollection
    @mediator = options.mediator
    @listenTo @collection, "reset", @initOverlays
    @listenTo @collection, "change", @filterData
    @listenTo @mediator, "url:selectedAll", @filterData
    # Not ideal, we are setting a class-global data object here.
    # This because of the `overlay.draw` method, used from the Google Maps API.
    # On map pan and zoom this method is called and it expects a `data` value
    # to be in scope.
    @data = null


  render: ->
    if @options.map_options
      @map = new google.maps.Map @el, @options.map_options

  filterData: (st) ->
    #console.log "Views.Map:filterData", st
    @data = @collection.parseDataForMap()
    _.each @data, (data, state) => @drawSvg data, state

      #state = data[0]?.state
      #@drawSvg data, state
    #@drawSvg @data


  # Derived from: https://gist.github.com/mbostock/899711
  initOverlays: ->
    self = this
    @data = @collection.parseDataForMap()
    # Create an overlay.
    overlay = new google.maps.OverlayView()
    #self.data = @collection.parseDataForMap()

    # Add the container when the overlay is added to the map.
    overlay.onAdd = ->
      layer = d3.select(@getPanes().overlayLayer)
        .append("div").attr("class", "locations")

      self.drawSvg = _.bind self.drawSvg, @, layer

    overlay.draw = ->
      _.each self.data, (data, state) => self.drawSvg data, state

    # Bind our overlay to the map…
    overlay.setMap @map


  # The function is partially applied with the `layer` argument
  # within the `overlay.onAdd` method.
  drawSvg: (layer, data, state) ->
    console.log "drawSvg", data.length, state
    transform = (d) ->
      #console.log "transform", d
      d = new google.maps.LatLng(d.lat, d.lng)
      d = projection.fromLatLngToDivPixel(d)
      d3.select(this)
        .style("left", (d.x - padding) + "px")
        .style("top", (d.y - padding) + "px")
    
    projection = @getProjection()
    padding = 10
    marker = layer.selectAll("svg.#{state}")
      .data(data, (d) -> d.visit_id)
      .each(transform) # update existing markers
    enter = marker.enter().append("svg:svg")
      .each(transform)
      .attr("class", "marker")
      .attr("class", state)
      .append("svg:circle")
      .attr("r", 4.5).attr("cx", padding).attr("cy", padding)
      .attr "class", (d) -> d.state
    exit = marker.exit()
      .each( (d) -> 
        #console.log "remove", d 
      )
      .remove()

    #marker.append("svg:text")
    #.attr("x", padding + 7)
    #.attr("y", padding)
    #.attr("dy", ".31em").text (d) ->
    #  d.value.visit_id
    