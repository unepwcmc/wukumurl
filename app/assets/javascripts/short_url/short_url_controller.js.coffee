# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(($)->

  $('.form-container').on('submit', 'form', (e) ->
    e.preventDefault()
    url = $('#url-to-shorten').val()

    $.ajax(
      url: '/'
      type: 'POST'
      data: {url:url}
    ).done((shortUrl)->
      $('#short-url-list').prepend("""
         <li>
           <div class="details">
             <a href="/#{shortUrl.short_name}">
               wcmc.io/#{shortUrl.short_name}
             </a>
             <div>
               <span class='stats'><a href="/short_urls/#{shortUrl.id}">0 visits</span></span>
               <a href="/short_urls/#{shortUrl.id}">view stats</a>
             </div>
             <p>#{shortUrl.url}</p>
           </div>
         </li>
       """)
    ).fail((response) ->
      errorMsg = ""
      for field, error of $.parseJSON(response.responseText)
        errorMsg += "#{field} #{error}\n"
      alert(errorMsg)
    )
    return false
  )


  ###
    Dynamically build the url for the `compare` page depending 
    on the clicks into the url checkboxes.
  ###
  
  updateUrl = (ids) ->
    url = "/compare/"
    _.each ids, (id) ->
      url += id + "/"
    url

  setUrlVisibility = (ids) ->
    if ids.length > 0
      link.show()
    else
      link.hide()
    
  ids = []
  link = $("a.compare_urls")
  # Resetting all .compare_urls checkboxes first.
  $('input:checkbox.compare_urls').removeAttr('checked')

  $("input:checkbox.compare_urls").on "click", (evt) ->
    val = evt.target.value
    val_pos = undefined
    _.each ids, (id, i) ->
      if id == val
        val_pos = i
    # If the url id is not in the list, add it!
    if val_pos == undefined
      ids.push val
    # But if it is already there, remove it!
    else
      ids.pop val_pos

    link.attr "href", updateUrl(ids)
    setUrlVisibility ids


)

