require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'GET show retrieves all the URLs created by the user' do
    user = FactoryGirl.create(:user)
    sign_in user

    short_urls = [
      FactoryGirl.create(:short_url, user: user),
      FactoryGirl.create(:short_url, user: user)
    ]

    (1..20).each do
      FactoryGirl.create(:visit, short_url: short_urls[1])
    end

    get :show
    assert_response :success

    assigned_urls = assigns(:short_urls)
    assert_not_nil assigned_urls

    assert_equal short_urls[1], assigned_urls.first

    assert_template :show
  end
end
