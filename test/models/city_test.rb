require 'test_helper'

class CityTest < ActiveSupport::TestCase
  test "::all_visits_by_country should return all countries with visit counts
    for all short urls" do

    st_lucia = FactoryGirl.create(:city, country: 'St Lucia')
    samoa = FactoryGirl.create(:city, country: 'Samoa')

    hacker_news = FactoryGirl.create(:short_url,
      url: 'http://news.ycombinator.com')
    bbc = FactoryGirl.create(:short_url, url: 'http://bbc.co.uk')

    2.times{ FactoryGirl.create(:visit, city: st_lucia, short_url: hacker_news) }
    2.times{ FactoryGirl.create(:visit, city: samoa, short_url: hacker_news) }
    2.times{ FactoryGirl.create(:visit, city: samoa, short_url: bbc) }

    visits_by_country = City.all_visits_by_country

    assert_equal 2, visits_by_country.length,
      "Expected there to be two countries with visits"

    assert_equal 4, visits_by_country["Samoa"],
      "Expected Samoa to have a country visit count of 4"

    assert_equal 2, visits_by_country["St Lucia"],
      "Expected St Lucia to have a country visit count of 2"
  end
end
