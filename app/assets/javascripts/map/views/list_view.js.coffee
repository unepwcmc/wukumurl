window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.List extends Backbone.View

  el: "#url-list"

  #events:
    # This intercepts all click events inside the view! Do we really want this?
    #'click section': 'redirectToShortUrl'

  initialize: (options) ->
    @collection = options.shortUrlsCollection
    @listenTo @collection, "reset", @render

  render: ->
    console.log "render WukumUrl.Map.Views.List"
    template = JST['map/templates/list'] @collection.models
    @$el.html template