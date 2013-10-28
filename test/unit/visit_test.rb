require 'test_helper'

class VisitTest < ActiveSupport::TestCase
  def setup
    require 'geoip'
    @country_db = GeoIP::Country.new(GEO_IP_CONFIG['country_db'])
    @organisation_db = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])
  end

  test "Geolocate on a wcmc IP visit should set organization correctly" do
    wcmc_visit = visits(:wcmc_visit_hn_today)
    assert_nil wcmc_visit.organization

    wcmc_visit.geo_locate @country_db, @organisation_db
    assert_equal "World Conservation Monitoring Centre", wcmc_visit.organization.name
  end

  test "Geolocate on a wcmc IP visit should set city correctly" do
    wcmc_visit = visits(:wcmc_visit_hn_today)
    assert_nil wcmc_visit.city

    wcmc_visit.geo_locate @country_db, @organisation_db
    assert_equal "Cambridge", wcmc_visit.city.name
  end

  test "Geolocate on a wcmc IP visit should set location correctly" do
    wcmc_visit = visits(:wcmc_visit_hn_today)
    assert_nil wcmc_visit.location

    wcmc_visit.geo_locate @country_db, @organisation_db
    assert_equal 52.22, wcmc_visit.location.lat.round(2)
    assert_equal 0.1, wcmc_visit.location.lon.round(2)
  end

  test "Visit.un_geolocated should return only visits which have no country set" do
    assert Visit.un_geolocated.to_a.include?(visits(:wcmc_visit_hn_today)),
      "Expected ungeolocated Visits to contain HN visit"

    assert !Visit.un_geolocated.to_a.include?(visits(:old_canadian_geolocated)),
      "Expected ungeolocated to not contain old_canadian visit"
  end
end
