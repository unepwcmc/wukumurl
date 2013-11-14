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

  # Show/Hide full length table in dashboard
  $('.view-all').click( ->
    text = $(@).text()
    $(@).text( if text == "View All" then "Hide" else "View All")
    $(@).closest('div').find('tr.all').toggleClass('hidden')
  )

  # piechart section

  # data preparation
  v = global_data_config.visits_by_country
  country_threshold = 3
  colours = ["#777777", "#bbbbbb", "#dddddd", "#333333"]
  mainCountries = v[0..country_threshold - 1]
  otherCountriesData = v[country_threshold..v.length]
  otherCountries = _.reduce otherCountriesData, (result, item, index) -> 
    result.value += item.value
    result.country = "other" if result.country != "other"
    result
  totalVisits = 0
  pieData = _.map mainCountries.concat(otherCountries), (item, index, list) ->
    totalVisits += item.value
    item.color = colours[index]
    item

  # draw piechart
  pieOptions = {
    animation: false
  }
  ctx = document.getElementById("pie").getContext("2d")
  piechart = new Chart(ctx).Pie(pieData, pieOptions)

  # draw legend
  $("#pie-legend li").each( (index, el) ->
    percent = parseInt(pieData[index].value / totalVisits * 100) + "%"
    $(@).find("div").text percent
    $(@).find("span").text pieData[index].country
  )

  # modal section

  blanket = $('#blanket')
  infoModal = $('#info-modal')
  newLinkForm = $('#new-link-form-wrapper')

  toggleFirstTimeModal = (status) ->
    blanket[status]()
    infoModal[status]()

  toggleAddLinkTooltip = (status) ->
    newLinkForm[status]()

  toggleFirstTimeModal("show") if yes #global_data_config.no_urls_yet
  infoModal.find("button").click( (e) ->
    toggleFirstTimeModal "hide"
    toggleAddLinkTooltip "show"
  )

)
