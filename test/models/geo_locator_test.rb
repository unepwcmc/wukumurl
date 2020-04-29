require 'test_helper'

class GeoLocatorTest < ActiveSupport::TestCase
  test 'GeoLocator is a SideKiq worker' do
    included_modules = GeoLocator.included_modules
    assert included_modules.include? Sidekiq::Worker
  end
end
