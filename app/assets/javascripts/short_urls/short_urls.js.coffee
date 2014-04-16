$(($)->
  window.map = L.map('map', scrollWheelZoom: false).setView([55, 0], 3)
  L.tileLayer('https://dnv9my2eseobd.cloudfront.net/v3/cartodb.map-4xtxp73f/{z}/{x}/{y}.png', {
    attribution: 'Mapbox <a href="http://mapbox.com/about/maps" target="_blank">Terms & Feedback</a>'
  }).addTo(map)

  # Show/Hide full length table in dashboard
  $('#short_urls_table').on('click', '.view-all', ->
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

  $('body').on('click', (event) ->
    el = event.target
    $el = $(el)

    clickedInPopover = $el.parents('.popover').length > 0

    popoverToggles = $.find('[data-toggle="popover"]')
    clickedOnButton = $.inArray(el, popoverToggles) > -1

    unless clickedInPopover or clickedOnButton
      closePopover()
  )

  $('.new-link').on('click', toggleNewLink)

  closePopover = ->
    $(".popover").hide()
    $('.popover .error').removeClass('error')

  $('.sign-in, .sign-up').on('click', (event) ->
    event.preventDefault()

    # If the selected popover is currently visible
    if new RegExp("#{this.className}").test $('.popover:visible').attr('class')
      closePopover()
    else
      closePopover()
      $(".#{this.className}-form").show()
  )

  $('.alert').fadeIn( ->
    setTimeout( =>
      $(this).fadeOut()
    ,4000)
  )
)
