window.WukumUrl ||= {}
window.WukumUrl.Map ||= {}
window.WukumUrl.Map.Models ||= {}


class WukumUrl.Map.Models.City extends WukumUrl.Map.Models.BaseModel


class WukumUrl.Map.Models.Cities extends WukumUrl.Map.Models.BaseCollection

  model: window.WukumUrl.Map.Models.City

  url: '/map/cities'
