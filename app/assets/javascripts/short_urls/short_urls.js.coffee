$(($)->

  captcha_el = $("""
    <label for="not_a_robot">
      <input type="checkbox" name="not_a_robot" id="not_a_robot">
      I am not a robot
    </label>
  """)
  $('.form-container form').append(captcha_el)

  $('.form-container').on('submit', 'form', (e) ->
    e.preventDefault()

    data =
      url: $('#url_to_shorten').val()
      short_name: $('#short_name').val()
      not_a_robot: $('#not_a_robot').is(':checked')

    $.ajax(
      url: '/'
      type: 'POST'
      data: data
    ).done((shortUrl)->
      $('form').children().removeClass('error')

      $('#short-url-list').prepend("""
         <li>
           <div class="details">
             <input type="checkbox" value="#{shortUrl.id}" class="compare_urls">
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
      for field, error of $.parseJSON(response.responseText)
        $("##{field}, [for=#{field}]").addClass('error')
    )
    return false
  )

  new ZeroClipboard($(".copy-url"), moviePath: "/assets/ZeroClipboard.swf")

  $('#view-all').click( ->
    text = $(@).text()
    $(@).text( if text == "View All" then "Reduce" else "View All")
    $('#url-table tr.all').toggleClass('hidden')
  )
  
)
