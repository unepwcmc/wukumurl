window.WukumUrl ||= {}
window.WukumUrl.Compare ||= {}

$ ($) ->

  # Rearranges the data sent down by the server into a data-structure
  # that suits the bar_chart generator. 
  ###
  [
    {
      "max":18,
      "name":"Total counts",
      "values":[
        {
          "name":"soerprojectteam",
          "val":10
        },
        {
          "name":"45ed",
          "val":18
        }
      ]
    },
    {
      "max":18,
      "name":"Last month counts",
      "values":[
        {
          "name":"soerprojectteam",
          "val":10
        },
        {
          "name":"45ed",
          "val":18
        }
      ]
    }
  ]
  ###


  # TODO: need to refactor and generalize this function,
  # its logic should only depend on the arguments passed in.
  updateResults = (data, evt, entering) ->
    n = evt.name
    d = data
    url_el = $("#results_one_url span.results")
    total_count_el = $("#results_one_tot_res span.results")
    month_count_el = $("#results_one_mon_res span.results")
    if entering
      url_el.html "wcmc.io/#{evt.name}"
      total_count_el.html (_.find d[0].values, (el, idx) -> el.name == n).val
      month_count_el.html (_.find d[1].values, (el, idx) -> el.name == n).val
    else
      url_el.html ""
      total_count_el.html ""
      month_count_el.html ""

  WukumUrl.Compare.buildCounts = buildCounts = (data) ->
    total = 
      max: _.max(data, (d, i) -> d.visit_count)
        .visit_count
      name: "Total counts"
      values: []
    month = 
      max: _.max(data, (d, i) -> d.visits_this_month.length)
        .visits_this_month.length
      name: "This month counts"
      values: []
    _.each data, (d, i) ->
      t_count = d.visit_count
      total.values.push {name: d.short_name, val: t_count}
      m_count = d.visits_this_month.length
      month.values.push {name: d.short_name, val: m_count}
    [total, month]

  chart_data = buildCounts(WukumUrl.data)
  # Returns the chart function:
  barchart = WukumUrl.Charters.barChart()
  # Customize the chart:
  barchart.width 500
  barchart.height 600
  # Draw the chart:
  selection = d3.select("#chart_one")
  selection.data [chart_data]
  selection.call barchart

  updateResultsPartial = _.partial updateResults, chart_data
  dispatch.on "in.result", updateResultsPartial
  dispatch.on "out.result", updateResultsPartial




  








