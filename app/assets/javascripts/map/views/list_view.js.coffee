window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


WukumUrl.Map.Views.List = Backbone.View.extend

  el: "#url-list"

  initialize: (options) ->

  render: ->
    console.log "render WukumUrl.Map.Views.List"
    template = JST['map/templates/list'] @
    @$el.html template