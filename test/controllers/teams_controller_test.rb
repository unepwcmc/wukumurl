require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get show" do
    team = FactoryGirl.create(:team)

    get :show, id: team.id
    assert_response :success
  end
end
