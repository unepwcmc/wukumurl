$(($)->
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

  toggleFirstTimeModal("show") if no #global_data_config.no_urls_yet
  infoModal.find("button").click( (e) ->
    toggleFirstTimeModal "hide"
    toggleAddLinkTooltip "show"
  )

)
