window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}

Views = WukumUrl.Map.Views

WukumUrl.Map.Router = Backbone.Router.extend
  
  routes: 
    "": "index"

  initialize: (options) ->
    @main_view = new Views.MainView options

  index: ->
    console.log 'index'
    