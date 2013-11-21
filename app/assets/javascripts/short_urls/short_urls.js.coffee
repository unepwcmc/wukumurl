$(($)->
  window.map = L.map('map', scrollWheelZoom: false).setView([15, 0], 2)
  L.tileLayer('https://dnv9my2eseobd.cloudfront.net/v3/cartodb.map-4xtxp73f/{z}/{x}/{y}.png', {
    attribution: 'Mapbox <a href="http://mapbox.com/about/maps" target="_blank">Terms & Feedback</a>'
  }).addTo(map)

  # Show/Hide full length table in dashboard
  $('.view-all').click( ->
    text = $(@).text()
    $(@).text( if text == "View All" then "Hide" else "View All")
    $(@).closest('div').find('tr.all').toggleClass('hidden')
  )

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
