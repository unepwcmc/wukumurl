editLinkForm = $('.edit-link-form')
editLinkView = null
theShortUrl = null

$('.edit-link').on('click', (event) ->
  event.preventDefault()
  event.stopPropagation()
  buttonEl = $(event.target).closest('.edit-link').first()

  if editLinkView
    editLinkForm.hide()
    editLinkView.close()
    editLinkView = null
  else
    unless theShortUrl
      if ShortUrlsCollection?
        id = buttonEl.data('shortUrlId')
        theShortUrl = $.grep(ShortUrlsCollection, (e) ->
          e.id == id
        )[0]
      else
        theShortUrl = <%= @short_url.to_json.html_safe %>
      return false unless theShortUrl

    editLinkView = new Backbone.Views.EditLinkView({
      short_url: theShortUrl
    })
    editLinkView.eventAggregator.on('link_updated', (new_short_url) ->
      theShortUrl = new_short_url
    )
    editLinkForm.html(editLinkView.el)
    buttonPosition = buttonEl.position()
    formPositionTop = buttonPosition.top + buttonEl.height() + 20
    formPositionLeft = buttonPosition.left - (editLinkForm.width() / 2) + 20
    editLinkForm.css(
      top: formPositionTop + 'px',
      left: formPositionLeft + 'px'
    )
    editLinkForm.show()
)
