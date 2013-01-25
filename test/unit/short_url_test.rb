require 'test_helper'

class ShortUrlTest < ActiveSupport::TestCase
  test "visits_today should return only visits from today" do
    assert short_urls(:hn).visits_today.to_a.include?(visits(:wcmc_visit_hn_today))
    assert !short_urls(:hn).visits_today.to_a.include?(visits(:visit_hn_2_days_ago))
  end

  test "visits_this_week should return only visits from this week" do
    visits_this_week = short_urls(:hn).visits_this_week
    assert visits_this_week.to_a.include?(visits(:wcmc_visit_hn_today))
    assert visits_this_week.to_a.include?(visits(:visit_hn_2_days_ago))
    assert !visits_this_week.to_a.include?(visits(:visit_hn_2_weeks_ago))
  end

  test "visits_this_month should return only visits from this month" do
    visits_this_month = short_urls(:hn).visits_this_month
    assert visits_this_month.to_a.include?(visits(:wcmc_visit_hn_today))
    assert visits_this_month.to_a.include?(visits(:visit_hn_2_days_ago))
    assert visits_this_month.to_a.include?(visits(:visit_hn_2_weeks_ago))
    assert !visits_this_month.to_a.include?(visits(:old_canadian_geolocated))
  end

  test "visits_by_country should return stats correctly" do
    country_stats = short_urls(:wcmc).visits_by_country
    country_stats.each do |country|
      if country.name == "Canada"
        assert_equal 1, country.visit_count.to_i
      elsif country.name == "United States of America"
        assert_equal 2, country.visit_count.to_i
      else
        # Shouldn't happen
        assert ['United States of America', 'Canada'].include?(country.name)
      end
    end
  end

  test "saving a link with no http:// in front should have it inserted" do
    no_http = ShortUrl.create(url: "bbc.co.uk")
    assert_equal "http://bbc.co.uk", no_http.url
  end

  test "saving a link with http:// in front should not modify the url" do
    http = ShortUrl.create(url: "http://bbc.co.uk")
    assert_equal "http://bbc.co.uk", http.url
  end

  test "saving a link with https:// in front should not modify the url" do
    http = ShortUrl.create(url: "https://bbc.co.uk")
    assert_equal "https://bbc.co.uk", http.url
  end
end
