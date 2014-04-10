class window.PieChart
  colours: ["#317FCE", "#5D9EDB", "#8EBDE6", "#C5DDF2"]
  country_threshold: 3

  constructor: (visits) ->
    topThreeCountries = @topThreeCountries(visits)
    debugger
    @visits = @populateColor(topThreeCountries)
    if @visits.length > 0
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
    sortedVisits = _.sortBy(visits, 'value').reverse()
    mainCountries = sortedVisits[0..@country_threshold - 1]

    otherCountriesData = sortedVisits[@country_threshold..sortedVisits.length]
    otherCountries = _.reduce(otherCountriesData, (result, item, index) ->
      result.value += item.value
      result.country = "other" if result.country != "other"

      return result
    )

    return mainCountries.concat(otherCountries || [])

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
