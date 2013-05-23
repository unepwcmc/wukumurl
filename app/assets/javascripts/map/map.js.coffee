window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}

options = {}
options.mediator = _.clone(Backbone.Events)
options.map_options = 
  center: new google.maps.LatLng(18, 0)
  zoom: 1
  mapTypeId: google.maps.MapTypeId.ROADMAP

shortUrls = new window.WukumUrl.Map.Models.ShortUrls options
shortUrls.fetch 
  error: -> console.log(arguments) # sends HTTP GET to /list
  reset: true

options.shortUrlsCollection = shortUrls

$(document).ready ->
  mapRouter = new WukumUrl.Map.Router options
  Backbone.history.start()