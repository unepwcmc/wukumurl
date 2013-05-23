window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Models ||= {}


class WukumUrl.Map.Models.ShortUrls extends Backbone.Collection

  model: window.WukumUrl.Map.Models.ShortUrl

  url: '/map/list'

  initialize: (options) ->
    @mediator = options.mediator