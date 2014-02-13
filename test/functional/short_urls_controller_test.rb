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

  test "GET show redirects to home page if ShortUrl doesn't exist" do
    get :show, short_name: "GOB"
    assert_redirected_to :root
  end

  test "POST create fails when no url to shorten is supplied" do
    sign_in FactoryGirl.create(:user)
    post :create
    assert_response :unprocessable_entity
  end

  test "POST create fails when no user is signed in" do
    post :create
    assert_response :redirect
  end

  test "POST create associates the logged in user with the ShortUrl" do
    user = FactoryGirl.create(:user)
    sign_in user

    post :create, url: 'http://google.com', user: user
    assert_response :success

    short_url = ShortUrl.last
    assert_equal user.id, short_url.user.id
  end

  test "POST create should add URLs using short_name if present" do
    post(
      :create, url: "http://envirobear.com", short_name: "xxx"
    )
    assert_equal ShortUrl.last.short_name, "xxx"
  end

  test "DELETE deletes the short URL if the user is signed in" do
    sign_in FactoryGirl.create(:user)
    short_url = FactoryGirl.create(:short_url)

    assert_difference('ShortUrl.count', -1) do
      delete :destroy, id: short_url.id
    end

    assert_redirected_to :root
  end

  test "DELETE does not delete the short URL if the user is not signed in" do
    short_url = FactoryGirl.create(:short_url)

    assert_difference('ShortUrl.count', 0) do
      delete :destroy, id: short_url.id
    end

    assert_redirected_to '/users/sign_in'
  end

  test "POST update should update the URLs short_name if user is signed in" do
    sign_in FactoryGirl.create(:user)
    short_url = FactoryGirl.create(:short_url, short_name: "xxx")

    post( :update, id: short_url.id, short_url: {short_name: 'zzz'} )

    short_url.reload
    assert_equal short_url.short_name, "zzz"
  end

  test "POST update should not update the URLs short_name if user is not signed in" do
    short_url = FactoryGirl.create(:short_url, short_name: "xxx")

    id = ShortUrl.last[:id]
    short_url = {:short_name => "zzz"}
    post( :update, {id: id, short_url: short_url} )
    assert_equal ShortUrl.last.short_name, "xxx"
  end
end
