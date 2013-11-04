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
end
