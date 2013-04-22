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


  shorten = (str) ->
    if str.length > 44
      return str.substring(0, 45) + "..."
    str

  # TODO: need to refactor and generalize this function,
  # its logic should only depend on the arguments passed in.
  updateResults = (data, d, i, entering) ->
    # Sniffing the name, because the function is called from different 
    # events with different d meanings.
    n = d.name
    d = data
    url_el = $("#results_one_url span.results")
    total_count_el = $("#results_one_tot_res span.results")
    month_count_el = $("#results_one_mon_res span.results")
    if entering
      full_url = _.find(d[0].values, (el, idx) -> el.name == n).url
      url_el.html shorten(full_url)
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
      name: "Total clicks"
      values: []
    month = 
      max: _.max(data, (d, i) -> d.visits_this_month.length)
        .visits_this_month.length
      name: "This month clicks"
      values: []
    _.each data, (d, i) ->
      t_count = d.visit_count
      total.values.push {name: d.short_name, val: t_count, url: d.url, id: d.id}
      m_count = d.visits_this_month.length
      month.values.push {name: d.short_name, val: m_count, url: d.url, id: d.id}
    [total, month]

  chart_data = buildCounts(WukumUrl.data.urls)
  # We want the data to reflect the order of selection in the landing page:
  _.each chart_data, (obj, i) ->
    chart_data[i].values = _.sortBy obj.values, (value) ->
       WukumUrl.data.url_ids.indexOf value.id   

  # Returns the chart function:
  barchart = WukumUrl.Charters.barChart()
  # Customize the chart:
  barchart.width 600
  barchart.height 500
  barchart.margin
   top: 20
   right: 250
   bottom: 20
   left: 30
  barchart.events ["onHover"]
  # Draw the chart:
  selection = d3.select("#chart_one")
  selection.data [chart_data]
  selection.call barchart

  updateResultsPartial = _.partial updateResults, chart_data
  dispatch = WukumUrl.Charters.barChart.dispatch
  dispatch.on "onHover.result", updateResultsPartial





  








