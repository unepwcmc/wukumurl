window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}


class WukumUrl.Map.Views.MainView extends Backbone.View

  initialize: (options) ->
    @views = {}
    @views.map = new WukumUrl.Map.Views.Map options
    @views.list = new WukumUrl.Map.Views.List options
    @render()
  
  render: ->
    @views.map.render()
    #@views.list.render()