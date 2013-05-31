window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.List extends Backbone.View

  el: "#url-list"

  #events:
    #'click .watch': 'selectUrl'
    #'click .watch-all': 'toggleAll'

  initialize: (options) ->
    @collection = options.locationsCollection
    @mediator = options.mediator
    @listenTo @collection, "reset", @onDataReady
    @listenTo @mediator, "Views:Map:dataUpdated", @selectUrl
    @listenTo @mediator, "Views:Map:collectionChange", @onCollectionChange

  onDataReady: (collection) ->
    #@render()

  onCollectionChange: (collection) =>
    @collection = collection
    @render()

  render: (urls, state) ->
    template = JST['map/templates/list'] {urls: urls, state: state}
    @$el.html template

  getTarget: (e, urlId) ->
    if e
      return $(e.target)
    else
      return @$el.find "#url_#{urlId}"

  getNewState: (target, state) ->
    unless state
      return if (target.hasClass "active") then "active" else "inactive"
    return @collection.invertedState state

  selectUrl: (d, collection) ->
    #console.log "selectUrl", d
    model = collection.get d.location_id
    urls = model.groupByShortUrls collection.url_attribute
    state = d.state
    @render urls, state
