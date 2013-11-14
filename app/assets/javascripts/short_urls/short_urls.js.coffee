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

class window.PieChart
  colours: ["#777777", "#bbbbbb", "#dddddd", "#333333"]
  country_threshold: 3

  constructor: (visits) ->
    topThreeCountries = @topThreeCountries(visits)
    @visits = @populateColor(topThreeCountries)

    @render()

  calculateTotalVisits: ->
    totalVisits = 0

    _.each(@visits, (item) =>
      totalVisits += item.value
    )

    return totalVisits

  populateColor: (visits) ->
    _.map(visits, (item, index, list) =>
      item.color = @colours[index]
      return item
    )

  topThreeCountries: (visits) ->
    mainCountries = visits[0..@country_threshold - 1]

    otherCountriesData = visits[@country_threshold..visits.length]
    otherCountries = _.reduce(otherCountriesData, (result, item, index) ->
      result.value += item.value
      result.country = "other" if result.country != "other"

      return result
    )

    return mainCountries.concat(otherCountries)

  render: ->
    pieOptions = {
      animation: false
    }

    context = $('.pie-chart canvas').get(0).getContext("2d")
    new Chart(context).Pie(@visits, pieOptions)

    @renderLegend()

  renderLegend: ->
    legendTemplate = _.template("""
      <li>
        <div class="legend-colour" style="background-color: <%= colour %>">
          <%= percent %>
        </div>
        <span class="legend-text">
          <%= country %>
        </span>
      </li>
    """)
    $legendEl = $(".pie-chart .legend")

    totalVisits = @calculateTotalVisits()

    _.each(@visits, (item, index) =>
      percent = parseInt(item.value / totalVisits  * 100) + "%"

      $legendEl.append(
        legendTemplate(
          percent: percent
          country: item.country
          colour: item.color
        )
      )
    )
