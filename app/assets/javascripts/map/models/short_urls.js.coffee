window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Models ||= {}


class WukumUrl.Map.Models.ShortUrls extends Backbone.Collection

  model: window.WukumUrl.Map.Models.ShortUrl

  url: '/map/list'

  initialize: (options) ->
    @mediator = options.mediator

  parseDataForMap: ->
    data = {}
    data.inactive = []
    data.active = []
    @each (model) ->
      _.each model.get("visits_location"), (v) ->
        unless v.lat == null or v.lon == null
          state = model.get "state"
          d = {}
          d.url_id = model.get "id"
          d.visit_id = v.location_id
          d.lat = v.lat
          d.lng = v.lon
          d.state = state
          if state == "active"
            data.active.push d
          else
            data.inactive.push d
    data

  # Given a collection of visits_location(s),
  # do not return the visits with no lat or lng.
  removeNoGeo: ->
    @filter (model) ->
      _.find model.get("visits_location"), (v) ->
        v.lat or v.lon

  getActiveUrls: ->
    @removeNoGeo().filter (model) ->
      model.get("state") == "active"

  getState: ->
    l = @getActiveUrls().length
    if l > 0
      return "active"
    return "inactive"

