window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}

options = {}
options.mediator = _.clone(Backbone.Events)
options.map_options = 
  center: new google.maps.LatLng(18, 0)
  zoom: 2
  mapTypeId: google.maps.MapTypeId.TERRAIN
location_options = _.extend({url_attribute: "location_urls"}, options) 
city_options = _.extend({url_attribute: "city_urls"}, options)


locations = new window.WukumUrl.Map.Models.Locations location_options
cities = new window.WukumUrl.Map.Models.Cities city_options
locations.fetch 
  error: -> console.log(arguments) # sends HTTP GET to /list
  reset: true
cities.fetch
  error: -> console.log(arguments) # sends HTTP GET to /list
  reset: true

options.locationsCollection = locations
options.citiesCollection = cities

$(document).ready ->
  mapRouter = new WukumUrl.Map.Router options
  Backbone.history.start()