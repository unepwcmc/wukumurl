require 'test_helper'

class ShortUrlsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "GET index renders a list of shortened URLs ordered by visits" do
    short_urls = [
      FactoryGirl.create(:short_url),
      FactoryGirl.create(:short_url)
    ]

    (1..20).each do
      FactoryGirl.create(:visit, short_url: short_urls[1])
    end

    get :index
    assert_response :success

    assigned_urls = assigns(:short_urls)
    assert_not_nil assigned_urls

    assert_equal short_urls[1], assigned_urls.first

    assert_template :index
  end

  test "can access a ShortUrl info page by appending /info to the link" do
    short_url = FactoryGirl.create(:short_url)
    get :show, short_name: short_url.short_name
    assert_response :success
  end

  test "GET show works via the route /short_urls/:id" do
    short_url = FactoryGirl.create(:short_url)
    get :show, id: short_url.id
    assert_response :success
  end

  test "GET show redirects to home page if ShortUrl doesn't exist" do
    get :show, short_name: "GOB"
    assert_redirected_to :root
  end

  test "POST create fails when no url to shorten is supplied" do
    post :create
    assert_response :unprocessable_entity
  end

  test "POST create associates the logged in user with the ShortUrl" do
    user = FactoryGirl.create(:user)
    sign_in user

    post :create, url: 'http://google.com', user: user, not_a_robot: "true"
    assert_response :success

    short_url = ShortUrl.last
    assert_equal user.id, short_url.user.id
  end

  test "DELETE destroy marks a ShortUrl as deleted, but does not delete it" do
    short_url = FactoryGirl.create(:short_url)

    assert_difference('ShortUrl.count', 0) do
      delete :destroy, id: short_url.id
    end

    assert_redirected_to :root
  end

  test "POST create should add URLs if non_robot parameter is true" do
    post :create, url: "http://envirobear.com", not_a_robot: "true"
    assert_response :success
  end

  test "POST create should not add URLs if non_robot parameter is false" do
    post :create, url: "http://news.ycombinator.com"
    assert_response :unprocessable_entity

    errors = {"not_a_robot" => ["must be checked"]}
    response_errors = JSON.parse(response.body)
    assert_equal errors, response_errors
  end
end
