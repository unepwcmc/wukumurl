class UrlLocation < ActiveRecord::Base
  # attr_accessible :title, :body
require 'geocoder'
require 'geoip'
  

#Uses geocoder to get lat/lon
  def self.get_location_from_geocoder ip_address
    latitude = Geocoder::coordinates(@address)[0]
    longitude = Geocoder::coordinates(@address)[1]
  end


end
