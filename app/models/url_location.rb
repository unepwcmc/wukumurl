class UrlLocation < ActiveRecord::Base
  # attr_accessible :title, :body
require 'geocoder'

#Uses geocoder to get lat/lon
  def get_location_from_geocoder(address)
    latitude = Geocoder::coordinates(@address)[0]
    longitude = Geocoder::coordinates(@address)[1]
  end

  def get_location_from_geoip(address)
    latitude = Geocoder::coordinates(@address)[0]
    longitude = Geocoder::coordinates(@address)[1]
  end



end
