require 'test_helper'

class ShortUrlTest < ActiveSupport::TestCase
  test "visits_today should return only visits from today" do
    assert_equal 1, short_urls(:hn).visits_today.count
    assert_equal visits(:wcmc_visit_hn_today), short_urls(:hn).visits_today[0]
  end

  test "visits_this_week should return only visits from this week" do
    assert_equal 2, short_urls(:hn).visits_this_week.count
    assert_equal [visits(:wcmc_visit_hn_today), visits(:visit_hn_2_days_ago)], short_urls(:hn).visits_this_week
  end

  test "visits_this_month should return only visits from this month" do
    assert_equal 3, short_urls(:hn).visits_this_month.count
    assert_equal [visits(:wcmc_visit_hn_today), visits(:visit_hn_2_days_ago),visits(:visit_hn_2_weeks_ago)], short_urls(:hn).visits_this_month
  end
end
