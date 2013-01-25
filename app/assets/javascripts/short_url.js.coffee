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
           <div class="details">
             <div>
               #{shortUrl.url}
                 <a href="/#{shortUrl.short_name}">
                   wcmc.io/#{shortUrl.short_name}
                 </a>
               <span class='stats'><a href="/short_urls/#{shortUrl.id}">0 visits</span></span>
             </div>
             <button class="btn">copy</button>
           </div>
         </li>
       """)
    )
    return false
  )
)

