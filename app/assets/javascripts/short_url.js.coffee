# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(($)->
  $('.form-container').on('submit', 'form', (e) ->
    e.preventDefault()
    url = $('#url-to-shorten').val()

    $.post('/', {url:url}, (shortUrl)->
      $('#short-url-list').prepend("""
         <li>
           <p>#{shortUrl.url}
             <a href="/#{shortUrl.short_name}">
               wcmc.io/#{shortUrl.short_name}<span>0 clicks</span>
             </a>
           </p>
           <button class="btn">copy</button>
         </li>
       """)
    )
    return false
  )
)

