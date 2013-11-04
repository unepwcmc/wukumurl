require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  test "DELETE :destroy marks an Organisation as disregarded, but does not delete it" do
    @request.env['HTTP_REFERER'] = '/'

    organization = FactoryGirl.create(:organization)

    assert_equal 0, organization.disregard
    assert_equal 1, Organization.count

    delete :destroy, id: organization.id
    assert_response :redirect

    organization.reload

    assert_equal 1, organization.disregard,
      "Expected Organization disregard count to be 1, but is \"#{organization.disregard}\""
    assert_equal 1, Organization.count
  end

  test "DELETE :destroy increments an Organization's disregarded count if it exists" do
    @request.env['HTTP_REFERER'] = '/'

    organization = FactoryGirl.create(:organization)

    assert_equal 0, organization.disregard
    assert_equal 1, Organization.count

    delete :destroy, id: organization.id
    assert_response :redirect

    delete :destroy, id: organization.id
    assert_response :redirect

    organization.reload

    assert_equal 2, organization.disregard,
      "Expected Organization disregard count to be 2, but is \"#{organization.disregard}\""
    assert_equal 1, Organization.count
  end
end
