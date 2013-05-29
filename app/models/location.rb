class Location < ActiveRecord::Base
  attr_accessible :lat, :lon, :source
  has_many :visits

  def self.get_coordinates_using_geoip city_attributes
    location = Location.create({ "lat" => city_attributes[:latitude], 
                                 "lon" => city_attributes[:longitude], 
                                 "source" => "GeoIP" })
  end

  def self.get_coordinates_using_geocoder global_attributes
      coordinates = Geocoder::coordinates("#{global_attributes[:organization]} #{global_attributes[:city]} #{global_attributes[:country]}")
      location = Location.create({ "lat" => global_attributes[:latitude], 
                               "lon" => global_attributes[:longitude], 
                               "source" => "Geocoder" })
  end
end



