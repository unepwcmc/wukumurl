window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.List extends Backbone.View

  el: "#url-list"

  events:
    # This intercepts all click events inside the view! Do we really want this?
    'click .watch': 'selectShortUrl'
    'click .watch-all': 'toggleUrlList'

  initialize: (options) ->
    @collection = options.shortUrlsCollection
    @mediator = options.mediator
    @listenTo @collection, "reset", @onDataReady

  onDataReady: (collection) ->
    # Passing `inactive` because initially we are not showing the url list.
    @render "inactive"

  render: (active) ->
    #console.log "render WukumUrl.Map.Views.List"
    template = JST['map/templates/list'] {
      collection: @collection.removeNoGeo()
      state: active
    }
    @$el.html template

  selectShortUrl: (e) ->
    target = $(e.target)
    target.toggleClass("active")
    url_id = target.closest('li').attr('id').split("_")[1]
    goTo = if (target.hasClass "active") then "active" else "inactive"
    #@collection.each (model) -> model.set "state": "inactive", {silent: true}
    @collection.get(url_id).set "state", goTo
    @render "active"

  toggleUrlList: (e) ->
    target = $(e.target)
    target.toggleClass("active")
    goTo = if (target.hasClass "active") then "active" else "inactive"
    @collection.each (model) -> model.set "state": goTo, {silent: true}
    @mediator.trigger "url:selectedAll", goTo
    @render goTo

