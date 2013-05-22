class UrlLocation < ActiveRecord::Base
  # attr_accessible :title, :body
require 'geocoder'
require 'geoip'
  

#Uses geocoder to get lat/lon
  def self.get_location_from_geocoder address
    latitude = Geocoder::coordinates(@address)[0]
    longitude = Geocoder::coordinates(@address)[1]
  end

  def get_location_from_geoip 
    addressdb = GeoIP::City.new('/opt/GeoIP/share/GeoIP/GeoLiteCity.dat')
    result = db.look_up(@ip_address)
    latitude = Geocoder::coordinates(@address)[0]
    longitude = Geocoder::coordinates(@address)[1]
  end





end
