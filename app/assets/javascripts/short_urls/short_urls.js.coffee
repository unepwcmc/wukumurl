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


  # Edit Short Url Name section

  rootHasNotChanged = (url) ->
    re = /wcmc.io\//
    url.match(re)

  removeRoot = (url) ->
    url.replace /wcmc.io\//, ""

  $('form.inline').submit (e) -> 
    e.preventDefault()
    current_short_url_val = $('#short_url').val()
    current_short_url_name = removeRoot current_short_url_val
    short_url = $('#short_url')
    short_url_val = short_url.val()
    short_url_name = removeRoot short_url_val
    short_url_id = e.target[0].name
    if rootHasNotChanged(short_url_val)
      data =
        new_name: short_url_name
        id: short_url_id
      $.ajax(
        url: "/short_urls/#{short_url_id}"
        type: 'PUT'
        data: data
      ).done((shortUrl)->
        current_short_url_val = "wcmc.io/#{shortUrl.new_name}"
        current_short_url_name = shortUrl.new_name
        $('#short_url').val current_short_url_val
      ).fail((jqXHR, textStatus) ->
        console.log textStatus 
      )
    else
      #TODO: use something like https://github.com/hxgf/smoke.js ?
      alert 'The url root "wcmc.io/" can not be modified'
      short_url.val current_short_url_val
    return false
  
)
