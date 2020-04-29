require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  test 'log in from homepage redirects to my links' do
    get "/users/sign_in"
    assert_response :success

    user = FactoryGirl.create(:user)

    post_via_redirect "/users/sign_in", {
      user: {
        email: user.email,
        password: FactoryGirl.attributes_for(:user)[:password]
      }
    }, {
      HTTP_REFERER: root_url
    }

    assert_equal user_links_path, path
  end

  test 'log in from whatever page redirects to whatever page' do
    user = FactoryGirl.create(:user)
    short_url = FactoryGirl.create(:short_url)

    post_via_redirect "/users/sign_in", {
      user: {
        email: user.email,
        password: FactoryGirl.attributes_for(:user)[:password]
      }
    }, {
      HTTP_REFERER: short_url_info_path(short_url.short_name)
    }

    assert_equal short_url_info_path(short_url.short_name), path
  end

  test 'log out' do
    login_as FactoryGirl.create(:user)

    get_via_redirect "/logout"

    assert_equal '/', path
    assert_response :success
  end

  test 'sign up registers the user' do
    get "/register"
    assert_response :success

    post_via_redirect "/register",
      user: {
        email: "hats@unep-wcmc.org",
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
