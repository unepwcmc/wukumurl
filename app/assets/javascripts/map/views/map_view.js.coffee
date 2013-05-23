window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


WukumUrl.Map.Views.Map = Backbone.View.extend

  el: "#map-canvas"

  initialize: (@options) ->


  render: ->
    console.log "render WukumUrl.Map.Views.Map"
    if @options.map_options
      map = new google.maps.Map @el, @options.map_options
    