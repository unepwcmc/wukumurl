editLinkForm = $('.edit-link-form')
editLinkView = null

$('.edit-link').on('click', (event) ->
  event.preventDefault()
  event.stopPropagation()
  buttonEl = $(event.target).closest('.edit-link').first()

  if editLinkView
    editLinkForm.hide()
    editLinkView.close()
    editLinkView = null
  else
    if ShortUrlsCollection?
      id = buttonEl.data('shortUrlId')
      shortUrl = $.grep(ShortUrlsCollection, (e) ->
        e.id == id
      )[0]
    else
      shortUrl = <%= @short_url.to_json.html_safe %>
    return false unless shortUrl

    editLinkView = new Backbone.Views.EditLinkView({
      short_url: shortUrl
    })
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
