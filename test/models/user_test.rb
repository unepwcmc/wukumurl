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

  test '.no_urls? returns false if the user has short urls' do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:short_url, user: user)

    refute user.no_urls?
  end

  test '.no_urls? returns true if the user has no short urls' do
    user = FactoryGirl.create(:user)

    assert user.no_urls?
  end

  test ".visits should return visits for short urls owned by User" do
    user = FactoryGirl.create(:user)
    user_short_url = FactoryGirl.create(:short_url, user: user)
    unowned_short_url = FactoryGirl.create(:short_url)

    user_visit_count = 5
    (1..user_visit_count).each do
      FactoryGirl.create(:visit, short_url: user_short_url)
    end

    unowned_visit_count = 10
    (1..unowned_visit_count).each do
      FactoryGirl.create(:visit, short_url: unowned_short_url)
    end

    assert_equal user_visit_count, user.visits.length
  end
end
