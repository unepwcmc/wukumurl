require 'test_helper'

class ShortUrlTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "visits_today should return a count of visits today" do
    debugger
    assert_equal 1, short_urls(:hn).find.visits_today
  end
end
