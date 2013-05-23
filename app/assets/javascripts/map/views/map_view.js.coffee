window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.Map extends Backbone.View

  el: "#map-canvas"

  initialize: (@options) ->


  render: ->
    console.log "render WukumUrl.Map.Views.Map"
    if @options.map_options
      map = new google.maps.Map @el, @options.map_options
    