$(($)->

  cartodb.createVis('map', 'https://carbon-tool.cartodb.com/api/v2/viz/f17c0670-9fa0-11e3-892d-0e625a1c94a6/viz.json')

  # Show/Hide full length table in dashboard
  $('.expandable-table').on('click', '.view-all', ->
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
