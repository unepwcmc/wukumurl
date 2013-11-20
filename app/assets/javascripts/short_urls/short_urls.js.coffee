$(($)->
  #map
  map = L.map('map', scrollWheelZoom: false).setView([0, 0], 1)
  L.tileLayer('http://a.tile.stamen.com/toner/{z}/{x}/{y}.png', {
    attribution: 'stamen http://maps.stamen.com/'
  }).addTo(map)

  L.tileLayer("http://carbon-tool.cartodb.com/tiles/wcmc_io_organizations_visits_count/{z}/{x}/{y}.png", {
    maxZoom: 18
  }).addTo(map)

  # modal section
  modalOverlay = $('.modal-overlay')
  modal = $('.modal')

  modal.find("button").click( (e) ->
    modal.hide()
    modalOverlay.hide()

    toggleNewLink()
  )

  newLinkForm = $('.new-link-form')
  newLinkView = null
  toggleNewLink = (event) ->
    if newLinkView?
      newLinkForm.hide()
      newLinkView.close()
      newLinkView = null
    else
      newLinkView = new Backbone.Views.NewLinkView()
      newLinkForm.html(newLinkView.el)
      newLinkForm.show()

  $('.new-link').on('click', toggleNewLink)

  $('.sign-in').on('click', (event) ->
    event.preventDefault()
    $(".sign-in-form").toggle()
  )
)
