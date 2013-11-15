$(($)->
  new ZeroClipboard($(".copy-url"), moviePath: "/assets/ZeroClipboard.swf")

  # Show/Hide full length table in dashboard
  $('.view-all').click( ->
    text = $(@).text()
    $(@).text( if text == "View All" then "Hide" else "View All")
    $(@).closest('div').find('tr.all').toggleClass('hidden')
  )

  # modal section
  blanket = $('#blanket')
  infoModal = $('#info-modal')
  newLinkForm = $('#new-link-form-wrapper')

  toggleFirstTimeModal = (status) ->
    blanket[status]()
    infoModal[status]()

  toggleAddLinkTooltip = (status) ->
    newLinkForm[status]()

  toggleFirstTimeModal("show") if yes #global_data_config.no_urls_yet
  infoModal.find("button").click( (e) ->
    toggleFirstTimeModal "hide"
    toggleAddLinkTooltip "show"
  )

)

window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.NewLinkView extends Backbone.View
  template: JST['templates/new_link']

  events:
    'click #edit_name': 'toggleEditName'
    'click .create': 'saveLink'

  initialize: ->
    @render()

  saveLink: (event) =>
    event.preventDefault()

    data =
      url: @$el.find('#url').val()
      short_name: @$el.find('#short_name').val()

    $.ajax(
      url: '/'
      type: 'POST'
      data: data)
    .done(@renderSuccess)
    .fail(@renderFailure)

  toggleEditName: ->
    @$el
      .find('#short_name')
      .parent()
      .toggle()

  renderFailure: (error) ->
    console.log arguments

  renderSuccess: (shortUrl) =>
    template = JST['templates/link_added']
    @$el.html(template())
    return @

  render: ->
    @$el.html(@template())
    return @
