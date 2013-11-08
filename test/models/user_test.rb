require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "can create a User with multiple ShortUrl associations" do
    short_urls = [
      FactoryGirl.create(:short_url),
      FactoryGirl.create(:short_url)
    ]

    user = FactoryGirl.create(:user, short_urls: short_urls)

    assert_equal short_urls, user.short_urls
  end

  test "Only users with @unep-wcmc.org emails can be created" do
    user = User.create(email: "test@not-wcmc.org", password: 'password')

    refute user.errors.messages.empty?,
      "Expected creating a user with a non WCMC email to fail"

    assert_equal "is invalid", user.errors.messages[:email].first
  end
end
