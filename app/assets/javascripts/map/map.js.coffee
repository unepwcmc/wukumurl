window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}

options = {}
options.mediator = _.clone(Backbone.Events)
options.map_options = 
  center: new google.maps.LatLng(18, 0)
  zoom: 1
  mapTypeId: google.maps.MapTypeId.ROADMAP

$(document).ready ->
  mapRouter = new WukumUrl.Map.Router options
  Backbone.history.start()