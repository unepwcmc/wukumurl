window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.List extends Backbone.View

  el: "#url-list"

  events:
    # This intercepts all click events inside the view! Do we really want this?
    'click .watch': 'selectShortUrl'
    'click .watch-all': 'selectShortUrlAll'

  initialize: (options) ->
    @collection = options.shortUrlsCollection
    @mediator = options.mediator
    @listenTo @collection, "reset", @render

  render: ->
    #console.log "render WukumUrl.Map.Views.List"
    template = JST['map/templates/list'] @collection.removeNoGeo()
    @$el.html template

  selectShortUrl: (e) ->
    url_id = $(e.target).closest('li').attr('id').split("_")[1]
    @collection.each (model) -> model.set "active", false, {silent: true}
    @collection.get(url_id).set "active", true
    #@mediator.trigger "url:selected", url_id

  selectShortUrlAll: ->
    @collection.each (model) -> model.set "active", true, {silent: true}
    @mediator.trigger "url:selectedAll"
