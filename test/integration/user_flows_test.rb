require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  test 'log in' do
    get "/login"
    assert_response :success

    user = FactoryGirl.create(:user)

    post_via_redirect "/login",
      'user[email]' => user.email,
      'user[password]' => FactoryGirl.attributes_for(:user)[:password]

    assert_equal '/', path
  end

  test 'log out' do
    login_as FactoryGirl.create(:user)

    get_via_redirect "/logout"

    assert_equal '/', path
    assert_response :success
  end

  test 'sign up' do
    get "/register"
    assert_response :success

    post_via_redirect "/register",
      'user[email]' => "hats@boats.com",
      'user[password]' => "password",
      'user[password_confirmation]' => "password"

    assert_equal '/', path
    assert_response :success
  end

  teardown do
    Warden.test_reset!
  end
end
