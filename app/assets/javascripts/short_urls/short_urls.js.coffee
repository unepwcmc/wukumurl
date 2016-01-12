$(($)->
  southWest = L.latLng(-90, -180)
  northEast = L.latLng(90, 180)
  maxBounds = L.latLngBounds(southWest, northEast)

  L.mapbox.accessToken = 'pk.eyJ1IjoidW5lcHdjbWMiLCJhIjoiRXg1RERWRSJ9.taTsSWwtAfFX_HMVGo2Cug'
  window.map = L.mapbox.map(
    'map', 'unepwcmc.8ac2cdd1', {
      zoomControl: true,
      center: [43, 0],
      maxBounds: maxBounds
      zoom: 3
      minZoom: 2
    }
  )

  # Show/Hide full length table in dashboard
  $('.expandable-table').on('click', '.view-all', ->
    text = $(@).text()
    $(@).text( if text == "View All" then "Hide" else "View All")
    $(@).closest('div').find('tr.all').toggleClass('hidden')
  )

  L.mapbox.accessToken = 'pk.eyJ1IjoidW5lcHdjbWMiLCJhIjoiRXg1RERWRSJ9.taTsSWwtAfFX_HMVGo2Cug'




  # modal section
  modalOverlay = $('.modal-overlay')
  modal = $('.modal')

  modal.find("button").click( (e) ->
    modal.hide()
    modalOverlay.hide()
    document.cookie="hide_info_modal=true;path=/";
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
      newLinkView = new Backbone.Views.NewLinkView({
        is_beta: !!new_link.data('beta')
      })
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

  new_link = $('.new-link')
  new_link.on('click', toggleNewLink)


  closePopover = ->
    $(".popover").hide()
    $('.popover .error').removeClass('error')
    newLinkView = null

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
