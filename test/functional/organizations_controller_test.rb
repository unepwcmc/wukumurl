require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  test "DELETE :destroy marks an Organisation as diregarded, but does not delete it" do
    @request.env['HTTP_REFERER'] = '/'

    organization = FactoryGirl.create(:organization)

    assert !organization.disregard
    assert_equal 1, Organization.count

    delete :destroy, id: organization.id
    assert_response :redirect

    organization.reload

    assert organization.disregard,
      "Expected Organization disregard to be true, but is \"#{organization.disregard}\""
    assert_equal 1, Organization.count
  end
end
