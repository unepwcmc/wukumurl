#= require spec_helper
#= require underscore-min
#= require backbone-min-1.0.0
#= require laconic


#= require map/templates/map.jst
#= require map/templates/list.jst
#= require map/views/map_view
#= require map/views/list_view
#= require map/views/main_view
#= require map/router

window.WukumUrl ||= {}

describe "Router", ->

  mapRouter = null

  before ->
    options = {}
    options.mediator = _.clone(Backbone.Events)
    mapRouter = new WukumUrl.Map.Router options
    Backbone.history.start()


  describe "Route to", ->

    it "should route to #index", ->
      "/".should.route.to mapRouter, "index"