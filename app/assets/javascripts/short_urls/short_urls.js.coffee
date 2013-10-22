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


  ###
    Dynamically build the url for the `compare` page depending 
    on the clicks into the url checkboxes.
  ###

  updateUrl = (ids) ->
    url = "/compare/"
    _.each ids, (id) ->
      url += id + "/"
    url

  setUrl = (ids) ->
    if ids.length > 0
      # Uses laconic.js
      a = $.el.a {'href' : updateUrl(ids)}, 'Compare urls!'
    else
      a = 'Compare urls!'
    link.html a

  ids = []
  link = $("span.compare_urls")
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
      ids.splice val_pos, 1
    setUrl ids
)
