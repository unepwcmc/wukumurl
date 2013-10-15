window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Models ||= {}


class WukumUrl.Map.Models.Country extends WukumUrl.Map.Models.BaseModel


class WukumUrl.Map.Models.Countries extends WukumUrl.Map.Models.BaseCollection

  model: window.WukumUrl.Map.Models.Country

  url: '/map/countries'

  getMaxVal: ->
    m = @max (model) -> model.get("country_urls").length
    m.get("country_urls").length
