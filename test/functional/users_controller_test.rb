require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'GET show retrieves all the URLs created by the user' do
    sign_in FactoryGirl.create(:user)
    get :show
    assert_response :success

    assert_not_nil assigns(:short_urls)
    assert_template :show
  end
end
