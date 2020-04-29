#= require d3-3.1.5
#= require jquery
#= require jquery_ujs
#= require laconic
#= require underscore-min

#= require ./support/spec_data

#= require sinon
#= require sinon-chai
#= require chai-changes
#= require chai-factories
#= require chai-jquery
#= require chai-backbone


# set the Mocha test interface
# see http://visionmedia.github.com/mocha/#interfaces
#mocha.ui "bdd"

# ignore the following globals during leak detection
#mocha.globals ["YUI"]

# or, ignore all leaks
#mocha.ignoreLeaks()

# set slow test timeout in ms
mocha.timeout 1000

# Show stack trace on failing assertion.
chai.Assertion.includeStack = true

#beforeEach ->
#  window.page = $("#konacha")
