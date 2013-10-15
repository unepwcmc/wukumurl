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
    @listenTo @mediator, "Views:Map:collectionNameChange", 
      @onCollectionNameChange
    # TODO: this should be passed with some configuration.
    @collectionName = "countriesCollection"
    # Render intro text.
    @render()

  onDataReady: (collection) ->
    #@render()

  onCollectionChange: (collection) =>
    @collection = collection
    @render()

  onCollectionChange: (collection) =>
    @collection = collection
    @render()

  onCollectionNameChange: (collectionName) =>
    @collectionName = collectionName

  render: (d, model, urls, collectionName) ->
    template = JST['map/templates/list'] {
      urls: urls
      state: d?.state
      name: model?.get("name") or model?.get("organization")?.name or ""
      size: d?.size
      collectionName: collectionName
    }
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
    unless d
      return @render()
    model = collection.get d.id
    urls = model.groupByShortUrls collection.url_attribute
    @render d, model, urls, @collectionName