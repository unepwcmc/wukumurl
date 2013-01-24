require 'test_helper'

class VisitTest < ActiveSupport::TestCase
  test "Geolocate on a wcmc IP visit should set country and city correctly" do
    wcmc_visit = visits(:wcmc_visit_hn_today)
    assert_nil wcmc_visit.country
    wcmc_visit.geo_locate
    assert_equal "GB", wcmc_visit.country.iso
  end
end
