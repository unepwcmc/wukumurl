window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}

options = {}
options.mediator = _.clone(Backbone.Events)
options.map_options = 
  center: new google.maps.LatLng(-34.397, 150.644)
  zoom: 8
  mapTypeId: google.maps.MapTypeId.ROADMAP

$(document).ready ->
  mapRouter = new WukumUrl.Map.Router options
  Backbone.history.start()