window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}

gStyles = [
  featureType: "all"
  stylers: [saturation: -90]
,
  featureType: "administrative.country"
  elementType: "labels.text.fill"
  stylers: [
    "lightness": 35
  ]
,
  featureType: "administrative.locality"
  elementType: "labels.text.fill"
  stylers: [
    "lightness": 35
  ]
,
  featureType: "road.arterial"
  elementType: "geometry"
  stylers: [
    hue: "#00ffee"
  ,
    saturation: 50
  ]
,
  featureType: "poi.business"
  elementType: "labels"
  stylers: [visibility: "off"]
]

options = {}
options.mediator = _.clone(Backbone.Events)
options.map_options = 
  center: new google.maps.LatLng(18, 0)
  zoom: 2
  mapTypeId: google.maps.MapTypeId.ROADMAP
  styles: gStyles
location_options = _.extend({url_attribute: "location_urls"}, options)
city_options = _.extend({url_attribute: "city_urls"}, options)
countries_options = _.extend({url_attribute: "country_urls"}, options)

locations = new window.WukumUrl.Map.Models.Locations location_options
cities = new window.WukumUrl.Map.Models.Cities city_options
countries = new window.WukumUrl.Map.Models.Countries countries_options
locations.fetch 
  error: -> console.log(arguments) # sends HTTP GET to /locations
  reset: true
cities.fetch
  error: -> console.log(arguments) # sends HTTP GET to /cities
  reset: true
countries.fetch
  error: -> console.log(arguments) # sends HTTP GET to /countries
  reset: true

options.locationsCollection = locations
options.citiesCollection = cities
options.countriesCollection = countries

$(document).ready ->
  mapRouter = new WukumUrl.Map.Router options
  Backbone.history.start()