window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.Map extends Backbone.View

  el: "#map-canvas"

  initialize: (@options) ->
    @collection = @options.shortUrlsCollection
    @listenTo @collection, "reset", @renderOverlays


  render: ->
    console.log "render WukumUrl.Map.Views.Map"
    if @options.map_options
      @map = new google.maps.Map @el, @options.map_options


  parseDataForMap: ->
    data = []
    @collection.each (model) ->
      _.each model.get("visits_location"), (v) ->
        unless v.latitude == null or v.longitude == null
          d = {}
          d.url_id = model.get "id"
          d.visit_id = v.id
          d.lat = v.latitude
          d.lng = v.longitude
          data.push d
    data 


  renderOverlays: ->
    self = this
    # Create an overlay.
    overlay = new google.maps.OverlayView()
    data = @parseDataForMap()
    
    # Add the container when the overlay is added to the map.
    overlay.onAdd = ->
      layer = d3.select(@getPanes().overlayLayer)
        .append("div").attr("class", "locations")
      
      # Draw each marker as a separate SVG element.
      # We could use a single SVG, but what size would it have?
      overlay.draw = ->

        transform = (d) ->
          d = new google.maps.LatLng(d.value.lat, d.value.lng)
          d = projection.fromLatLngToDivPixel(d)
          d3.select(this)
            .style("left", (d.x - padding) + "px")
            .style "top", (d.y - padding) + "px"
        
        projection = @getProjection()
        padding = 10
        marker = layer.selectAll("svg")
          .data(d3.entries(data))
          .each(transform).enter().append("svg:svg")
          .each(transform).attr("class", "marker")
        marker.append("svg:circle")
          .attr("r", 6.5).attr("cx", padding).attr "cy", padding
        #marker.append("svg:text")
        #  .attr("x", padding - 3)
        #  .attr("y", padding)
        #  .attr("dy", ".31em").text (d) ->
        #    d.key
  
    # Bind our overlay to the map…
    overlay.setMap @map
    