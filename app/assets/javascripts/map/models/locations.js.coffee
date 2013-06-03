window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Models ||= {}


class WukumUrl.Map.Models.Location extends WukumUrl.Map.Models.BaseModel

  ###
  [

    {
      id: 1237,
      lat: 41.9603004455566,
      lon: -83.6735000610352,
      location_urls: [
      {
      short_name: "a43d",
      url: "http://www.unep-wcmc.org/version1_1009.html"
      },
      {
      short_name: "a43d",
      url: "http://www.unep-wcmc.org/version1_1009.html"
      }
      ]
    },
    .
    .
    .

  ]
  ###



class WukumUrl.Map.Models.Locations extends WukumUrl.Map.Models.BaseCollection

  model: window.WukumUrl.Map.Models.BaseModel

  url: '/map/locations'

  getMaxVal: ->
    m = @max (model) -> model.get("location_urls").length
    m.get("location_urls").length
