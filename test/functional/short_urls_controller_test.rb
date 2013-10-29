require 'test_helper'

class ShortUrlsControllerTest < ActionController::TestCase
  test "GET :index renders a list of shortened URLs" do
    get :index
    assert :success

    assert_not_nil assigns(:short_urls)
    assert_template :index
  end

  test "can access a ShortUrl info page by appending /info to the link" do
    short_url = short_urls(:hn)
    get :show, short_name: short_url.short_name
    assert :success
  end

  test "GET show works via the route /short_urls/:id" do
    short_url = short_urls(:hn)
    get :show, id: short_url.id
    assert :success
  end

  test "GET show redirects to home page if ShortUrl doesn't exist" do
    get :show, short_name: "GOB"
    assert_redirected_to :root
  end

  test "should add URLs if non_robot parameter is true" do
    post :create, url: "http://envirobear.com", not_a_robot: true
    assert :success
  end

  test "should not add URLs if non_robot parameter is false" do
    post :create, url: "http://news.ycombinator.com", not_a_robot: false
    assert :unprocessable_entity

    errors = {"not_a_robot" => ["must be checked"]}
    response_errors = JSON.parse(response.body)
    assert_equal errors, response_errors
  end
end
