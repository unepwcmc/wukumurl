window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Models ||= {}


class WukumUrl.Map.Models.ShortUrl extends Backbone.Model

  defaults: {
    state: "inactive"
  }

  ###
  #{
  #  id: 56,
  #  short_name: "51a1fe179246",
  #  url: "http://wcmc.io/short_urls/38",
  #  visit_count: 12,
  #  visits_location: [
  #    {
  #    id: 188,
  #    latitude: null,
  #    longitude: null
  #    },
  #    {
  #    id: 189,
  #    latitude: null,
  #    longitude: null
  #    }
  #  ]
  #}
  ###