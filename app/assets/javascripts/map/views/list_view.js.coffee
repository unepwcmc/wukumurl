window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Views ||= {}  


class WukumUrl.Map.Views.List extends Backbone.View

  el: "#url-list"

  #events:
    #'click .watch': 'selectUrl'
    #'click .watch-all': 'toggleAll'

  initialize: (options) ->
    @collection = options.shortUrlsCollection
    @mediator = options.mediator
    @listenTo @collection, "reset", @onDataReady
    @listenTo @mediator, "Views:Map:dataUpdated", @selectUrl

  onDataReady: (collection) ->
    #@render()

  render: (urls) ->
    #collection = @collection.getActiveUrls()
    console.log 'PPPP', urls
    template = JST['map/templates/list'] urls
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

  selectUrl: (d) ->
    #console.log "selectUrl", @collection.get d.location_id
    model = @collection.get d.location_id
    urls = model.groupByShortUrls()
    @render urls
    


  #selectUrl: (e, urlId, state) ->
  #  target = @getTarget e, urlId
  #  target.toggleClass("active")
  #  urlId or= target.closest('li').attr('id').split("_")[1]
  #  newState = @getNewState target, state
  #  @collection.get(urlId).set "state", newState
  #  @render()
#
  #toggleAll: (e) ->
  #  target = $(e.target)
  #  target.toggleClass("active")
  #  newState = if (target.hasClass "active") then "active" else "inactive"
  #  @collection.each (model) -> model.set "state": newState, {silent: true}
  #  @mediator.trigger "url:selectedAll", newState
  #  @render()

