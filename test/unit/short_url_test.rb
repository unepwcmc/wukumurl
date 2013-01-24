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
end
