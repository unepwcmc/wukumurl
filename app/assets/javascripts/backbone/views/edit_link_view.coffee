window.Backbone ||= {}
window.Backbone.Views ||= {}

class Backbone.Views.EditLinkView extends Backbone.View
  template: JST['backbone/templates/edit_link']

  events:
    'click .save': 'saveLink'

  initialize: (options = {}) ->
    @short_url = options.short_url
    @render()

  saveLink: (event) =>
    event.preventDefault()

    data =
      url: @$el.find('#url').val()
      short_name: @$el.find('#short_name').val()

    $.ajax(
      url: "/short_urls/#{@short_url.id}"
      type: 'PUT'
      data: data)
    .done(@renderSuccess)
    .fail(@renderFailure)

  render: ->
    @$el.html(@template(
      url: @short_url.url
      short_name: @short_url.short_name
    ))
    return @

  renderFailure: (response) ->
    for field, error of $.parseJSON(response.responseText)
      $("##{field}, [for=#{field}]").addClass('error')

  renderSuccess: (shortUrl) =>
    template = JST['backbone/templates/link_added']

    @$el.html(template(
      url: shortUrl.short_name
    ))

    new ZeroClipboard(
      @$el.find(".copy-url"),
      moviePath: "/assets/ZeroClipboard.swf"
    )

    return @

  close: ->
