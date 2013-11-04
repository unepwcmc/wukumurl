require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  test "Organisations can be marked as disregarded" do
    organisation = FactoryGirl.create(:organization, disregard: true)
    assert organisation.disregard,
      "Expected Organization to be able to be marked as disregarded"
  end
end
