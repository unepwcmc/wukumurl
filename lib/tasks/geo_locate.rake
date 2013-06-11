namespace :geo_locate do
  task visits: :environment do
    require 'geoip'

    cdb = GeoIP::Country.new(GEO_IP_CONFIG['country_db'])
    odb = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])

    Visit.un_geolocated.each do |visit|
      visit.geo_locate cdb, odb
      visit.save
    end
  end
end
