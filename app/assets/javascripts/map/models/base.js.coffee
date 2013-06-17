window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Models ||= {}


class WukumUrl.Map.Models.BaseCollection extends Backbone.Collection

  initialize: (options) ->
    @mediator = options.mediator
    @url_attribute = options.url_attribute

  # We need a unique id across country-city-location dots,
  # so d3 knows when to enter, update and exit.
  genUniqId: (lat, lng, id) ->
    lat + lng + id

  parseDataForMap: ->
    data = []
    @each (model) =>
      size = model.get(@url_attribute).length
      if size > 1
        lat = model.get "lat"
        lng = model.get "lon"
        id = parseInt model.get("id")
        d = {}
        d.lat = lat
        d.lng = lng
        d.state = model.get "state"
        d.size = size
        d.id = id
        d.uique_id = @genUniqId(lat, lng, id)
        data.push d
        data = _.uniq data, (d) -> d.uique_id
    @sortDataForMap data

  # Sort data so the bigger circles appear behind the smaller ones on the map.
  sortDataForMap: (data) ->
    _.sortBy data, (d) ->
      1/d.size

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

  # Given a state: "active" or "inactive", which is its inverted?
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
    urls = @.get url_attr
    _.groupBy urls, (url) -> url.short_name


  getNames: ->
    [model?.get("name")]