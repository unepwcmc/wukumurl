window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.NewLinkView extends Backbone.View
  template: JST['backbone/templates/new_link']

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

  render: ->
    @$el.html(@template())
    return @

  renderFailure: (response) ->
    for field, error of $.parseJSON(response.responseText)
      $("##{field}, [for=#{field}]").addClass('error')

  renderSuccess: (shortUrl) =>
    template = JST['backbone/templates/link_added']

    @$el.html(template(
      url: shortUrl.short_name
    ))

    @renderCopyButton()

    return @

  renderCopyButton: ->
    @clipboard = new ZeroClipboard(
      @$el.find(".copy-url"),
      moviePath: '/assets/ZeroClipboard.swf',
      hoverClass: 'hover'
    )

    @clipboard.on('complete', =>
      copiedText = @$el.find('.copied')
      copiedText.fadeIn()

      setTimeout( ->
        copiedText.fadeOut()
      , 2000)
    )

  close: ->
    @clipboard.off('complete')
