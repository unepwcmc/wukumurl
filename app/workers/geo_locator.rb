require 'geoip'
require 'geocoder'

class GeoLocator
  include Sidekiq::Worker

  def perform(visit_id)
    visit = Visit.find(visit_id)

    cdb = GeoIP::City.new(GEO_IP_CONFIG['city_db'])
    orgdb = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])

    visit.geo_locate cdb,orgdb
    visit.save
  end
end
