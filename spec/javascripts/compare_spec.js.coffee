#= require spec_helper
#= require compare


describe "Compare", ->

  describe "buildCounts", ->

    it "should be the right data type: max", ->
      server_data = spec_data.compare_short_urls
      client_data = WukumUrl.Compare.buildCounts server_data
      _.each client_data, (d, i) ->
        max = d.max
        isInteger = (typeof max == "number") && Math.floor(max) == max
        max.should.not.equal(undefined)
        isInteger.should.be.equal(yes)


  