editLinkForm = $('.edit-link-form')
editLinkView = null

$('.edit-link').on('click', (event) ->
  if editLinkView
    editLinkForm.hide()
    editLinkView.close()
    editLinkView = null
  else
    editLinkView = new Backbone.Views.EditLinkView({
      short_url: <%= @short_url.to_json.html_safe %>
    })
    editLinkForm.html(editLinkView.el)
    editLinkForm.show()
)
