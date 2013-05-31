window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Models ||= {}


class WukumUrl.Map.Models.BaseCollection extends Backbone.Collection

  initialize: (options) ->
    @mediator = options.mediator
    @url_attribute = options.url_attribute

  parseDataForMap: ->
    data = []
    @each (model) =>
      d = {}
      d.lat = model.get "lat"
      d.lng = model.get "lon"
      d.state = model.get "state"
      d.size = model.get(@url_attribute).length
      d.location_id = parseInt model.get("id")
      data.push d
      data = _.uniq data, (d) -> d.location_id
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

  invertedState: (state) ->
    if state == "inactive"
      return "active"
    if state == "active"
      return "inactive"
    throw new Error "State value should either be active or inactive, not: #{state}"

  resetState: ->
    @each (model) ->
      model.set "state", "inactive"



class WukumUrl.Map.Models.BaseModel extends Backbone.Model

  defaults: {
    state: "inactive"
  }

  groupByShortUrls: (url_attr) ->
    urls = @.get url_attr#"location_urls"
    _.groupBy urls, (url) -> url.short_name