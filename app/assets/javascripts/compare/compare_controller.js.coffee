
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
      #total.max = if total.max < t_count then t_count
      m_count = d.visits_this_month.length
      month.values.push {name: d.short_name, val: m_count}
      #month.max = if month.max < m_count then m_count
    [total, month]


  #console.log '@', buildCounts(WukumUrl.data)

  # Returns the chart function:
  barchart = WukumUrl.Charters.barChart()
  # Customize the chart:
  barchart.width 500
  barchart.height 600
  # Draw the chart:
  selection = d3.select("#chart_one").append "svg"
  selection.data [buildCounts(WukumUrl.data)]
  selection.call barchart

  #console.log JSON.stringify WukumUrl.data



  








