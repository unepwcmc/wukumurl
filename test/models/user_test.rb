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

  test ".visits_by_organization returns all organizations with visit
    counts for short urls owned by User" do
    user = FactoryGirl.create(:user)

    bt = FactoryGirl.create(:organization, name: 'BT')
    virgin = FactoryGirl.create(:organization, name: 'Virgin Media')
    plusnet = FactoryGirl.create(:organization, name: 'Plustnet')

    hacker_news = FactoryGirl.create(:short_url,
      url: 'http://news.ycombinator.com', user: user)
    bbc = FactoryGirl.create(:short_url, url: 'http://bbc.co.uk')

    FactoryGirl.create(:visit, organization: bt, short_url: hacker_news)
    FactoryGirl.create(:visit, organization: virgin, short_url: hacker_news)
    FactoryGirl.create(:visit, organization: plusnet, short_url: bbc)

    visits_by_organization = user.visits_by_organization

    assert_equal 2, visits_by_organization.length,
      "Expected there to be two organizations with visits"

    org_ids = visits_by_organization.map(&:id)

    assert org_ids.include?(virgin.id),
      "Expected organisations to contain Virgin"
    assert org_ids.include?(bt.id),
      "Expected organisations to contain BT"
  end

  test ".visits_by_country should return all countries with visit counts
    for short urls owned by user" do
    user = FactoryGirl.create(:user)

    st_lucia = FactoryGirl.create(:city, country: 'St Lucia')
    samoa = FactoryGirl.create(:city, country: 'Samoa')

    hacker_news = FactoryGirl.create(:short_url,
      url: 'http://news.ycombinator.com', user: user)
    bbc = FactoryGirl.create(:short_url, url: 'http://bbc.co.uk', user: user)

    FactoryGirl.create(:visit, city: st_lucia, short_url: hacker_news)
    FactoryGirl.create(:visit, city: samoa, short_url: hacker_news)
    FactoryGirl.create(:visit, city: samoa, short_url: bbc)

    visits_by_country = user.visits_by_country

    assert_equal 2, visits_by_country.length,
      "Expected there to be two countries with visits"

    assert_equal 2, visits_by_country["Samoa"],
      "Expected Samoa to have a country visit count of 2"

    assert_equal 1, visits_by_country["St Lucia"],
      "Expected St Lucia to have a country visit count of 1"
  end
end
