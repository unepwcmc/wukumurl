require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  test "Organisations can be marked as disregarded" do
    organisation = FactoryGirl.create(:organization, disregard: 1)
    assert_equal 1, organisation.disregard,
      "Expected Organization to be able to be marked as disregarded"
  end
end
