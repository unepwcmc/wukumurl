require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  test 'log in' do
    get "/login"
    assert_response :success

    user = FactoryGirl.create(:user)

    post_via_redirect "/login",
      user: {
        email: user.email,
        password: FactoryGirl.attributes_for(:user)[:password]
      }

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
      user: {
        email: "hats@boats.com",
        password: "password",
        password_confirmation: "password"
      }

    assert_equal '/', path
    assert_response :success
  end

  test 'forgotten password' do
    get "forgot_password"
    assert_response :success

    user = FactoryGirl.create(:user)

    post_via_redirect "/forgot_password",
      user: {
        email: user.email
      }

    mail = ActionMailer::Base.deliveries.last

    assert_equal user.email, mail['to'].to_s
    assert_equal "Reset password instructions", mail['subject'].to_s

    assert_response :success
  end

  test 'devise sends mail from the correct email' do
    get "forgot_password"
    assert_response :success

    user = FactoryGirl.create(:user)

    post_via_redirect "/forgot_password",
      user: {
        email: user.email
      }

    mail = ActionMailer::Base.deliveries.last

    assert_equal 'no-reply@unep-wcmc.org', mail['from'].to_s

    assert_response :success
  end

  teardown do
    Warden.test_reset!
  end
end
