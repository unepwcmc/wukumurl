window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Models ||= {}


class WukumUrl.Map.Models.ShortUrls extends Backbone.Collection

  model: window.WukumUrl.Map.Models.ShortUrl

  url: '/map/list'

  initialize: (options) ->
    @mediator = options.mediator

  parseDataForMap: ->
    data = []
    @each (model) ->
      _.each model.get("visits_location"), (v) ->
        unless v.latitude == null or v.longitude == null
          d = {}
          d.url_id = model.get "id"
          d.visit_id = v.id
          d.lat = v.latitude
          d.lng = v.longitude
          data.push d
    data

  # Given a collection of visits_location(s),
  # do not return the visits with no lat or lng.
  removeNoGeo: ->
    @filter (model) ->
      _.find model.get("visits_location"), (v) ->
        v.latitude or v.longitude

