require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test 'GET show retrieves all the URLs created by the user' do
    get :show, id: FactoryGirl.create(:user).id
    assert_response :success

    assert_not_nil assigns(:short_urls)
    assert_template :show
  end
end
