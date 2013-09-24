require 'test_helper'

class ShortUrlsControllerTest < ActionController::TestCase
  test "should add URLs if non_robot parameter is true" do
    post :create, url: "http://envirobear.com", not_a_robot: true
    assert :success

    assert_equal "http://envirobear.com", ShortUrl.last.url
  end

  test "should not add URLs if non_robot parameter is false" do
    post :create, url: "http://news.ycombinator.com", not_a_robot: false
    assert :unprocessable_entity

    errors = {"not_a_robot" => ["must be checked"]}
    response_errors = JSON.parse(response.body)
    assert_equal errors, response_errors
  end
end
