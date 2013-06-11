require 'test_helper'

class VisitTest < ActiveSupport::TestCase
  test "Geolocate on a wcmc IP visit should set country and organization correctly" do
    wcmc_visit = visits(:wcmc_visit_hn_today)
    assert_nil wcmc_visit.country

    require 'geoip'
    cdb = GeoIP::Country.new(GEO_IP_CONFIG['country_db'])
    odb = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])

    wcmc_visit.geo_locate cdb, odb
    assert_equal "GB", wcmc_visit.country.iso
    assert_equal "World Conservation Monitoring Centre", wcmc_visit.organization.name
  end

  test "Visit.un_geolocated should return only visits which have no country set" do
    assert Visit.un_geolocated.to_a.include?(visits(:wcmc_visit_hn_today))
    assert !Visit.un_geolocated.to_a.include?(visits(:old_canadian_geolocated))
  end
end
