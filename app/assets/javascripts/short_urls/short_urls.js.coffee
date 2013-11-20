

$(($)->
  #map
  map = L.map('map', scrollWheelZoom: false).setView([15, 0], 2)
  L.tileLayer('https://dnv9my2eseobd.cloudfront.net/v3/cartodb.map-4xtxp73f/{z}/{x}/{y}.png', {
    attribution: 'Mapbox <a href="http://mapbox.com/about/maps" target="_blank">Terms & Feedback</a>'
  }).addTo(map);

  L.tileLayer("http://carbon-tool.cartodb.com/tiles/wcmc_io_organizations_visits_count/{z}/{x}/{y}.png", {
    maxZoom: 18
  }).addTo(map)

  # Show/Hide full length table in dashboard
  $('.view-all').click( ->
    text = $(@).text()
    $(@).text( if text == "View All" then "Hide" else "View All")
    $(@).closest('div').find('tr.all').toggleClass('hidden')
  )

  # modal section
  blanket = $('.modal-overlay')
  infoModal = $('#info-modal')

  toggleFirstTimeModal = (status) ->
    blanket[status]()
    infoModal[status]()

  toggleAddLinkTooltip = (status) ->
    newLinkForm[status]()

  newLinkForm = $('.new-link-form')
  newLinkView = null
  $('.new-link').on('click', (event) ->
    if newLinkView?
      newLinkForm.hide()
      newLinkView.close()
      newLinkView = null
    else
      newLinkView = new Backbone.Views.NewLinkView()
      newLinkForm.html(newLinkView.el)
      newLinkForm.show()
  )

  $('.sign-up, .sign-in').on('click', (event) ->
    event.preventDefault()
    $(".#{@className}-form").toggle()
  )

  toggleFirstTimeModal("show") if no #global_data_config.no_urls_yet
  infoModal.find("button").click( (e) ->
    toggleFirstTimeModal "hide"
    toggleAddLinkTooltip "show"
  )

)
