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
)

