require 'test_helper'

class VisitTest < ActiveSupport::TestCase
  def setup
    require 'geoip'
    @country_db = GeoIP::Country.new(GEO_IP_CONFIG['country_db'])
    @organisation_db = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])
  end

  test "Geolocate on a wcmc IP visit should set organization, city,
    location correctly" do
    wcmc_visit = FactoryGirl.create(:visit, ip_address: "194.59.188.126")

    assert_nil wcmc_visit.organization
    assert_nil wcmc_visit.city
    assert_nil wcmc_visit.location

    wcmc_visit.geo_locate @country_db, @organisation_db

    assert_equal "World Conservation Monitoring Centre", wcmc_visit.organization.name
    assert_equal "United Kingdom", wcmc_visit.city.country
    assert_equal 52.22, wcmc_visit.location.lat.round(2)
    assert_equal 0.1, wcmc_visit.location.lon.round(2)
  end

  test "Visit.un_geolocated should return only visits which have no country set" do
    ungeolocated_visit = FactoryGirl.create(:visit)
    assert Visit.un_geolocated.to_a.include?(ungeolocated_visit),
      "Expected ungeolocated Visits to contain ungeolocated_visit"

    geolocated_visit = FactoryGirl.create(:visit, city: FactoryGirl.build(:city))
    refute Visit.un_geolocated.to_a.include?(geolocated_visit),
      "Expected ungeolocated Visits to not contain geolocated Visit"
  end
end
