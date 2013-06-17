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

  mapRouter = mainViewInitSpy = mapViewInitSpy = listViewInitSpy = null

  before ->
    MainView = WukumUrl.Map.Views.MainView
    MapView = WukumUrl.Map.Views.Map
    ListView = WukumUrl.Map.Views.List

    mainViewInitSpy = sinon.spy MainView.prototype, "initialize"
    mapViewInitSpy = sinon.spy MapView.prototype, "initialize"
    listViewInitSpy = sinon.spy ListView.prototype, "initialize"
    
    options = {}
    options.mediator = _.clone(Backbone.Events)
    mapRouter = new WukumUrl.Map.Router options
    Backbone.history.start()

  after ->
    mainViewInitSpy.restore()
    mapViewInitSpy.restore()
    listViewInitSpy.restore()


  describe "Route to", ->

    it "should route to #index", ->
      "/".should.route.to mapRouter, "index"


  describe "On Router init", ->

    it "Main, Map and List Views shuld be called", ->
      mainViewInitSpy.calledOnce.should.equal true
      mapViewInitSpy.calledOnce.should.equal true
      listViewInitSpy.calledOnce.should.equal true
