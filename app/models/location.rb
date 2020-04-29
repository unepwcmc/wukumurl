class Location < ActiveRecord::Base
  has_many :visits
  has_many :short_urls, :through => :visits

  def self.get_coordinates_using_geoip city_attributes
    location_attributes = { "lat" => city_attributes[:latitude], 
                                 "lon" => city_attributes[:longitude], 
                                 "source" => "GeoIP" }
    Location.where(location_attributes).first || Location.create(location_attributes)
  end

  def self.get_coordinates_using_geocoder global_attributes
    geocoder_coordinates = Geocoder::coordinates("#{global_attributes[:name]} #{global_attributes[:city]} #{global_attributes[:country_name]}")
    if geocoder_coordinates
      location_attributes = { "lat" => geocoder_coordinates[0], 
                   "lon" => geocoder_coordinates[1], 
                   "source" => "Geocoder" }
      return Location.where(location_attributes).first || Location.create(location_attributes)
    else
      location_attributes = { "lat" => global_attributes[:latitude], 
                              "lon" => global_attributes[:longitude], 
                              "source" => "GeoIP" }
      return Location.where(location_attributes).first || Location.create(location_attributes)
    end
  end

  def location_urls
    Location.where(id: self.id).joins(:short_urls).select([:short_name, :url])
  end

  #TODO: need to return organizations, not only first
  def organization
    id = Location.where(id: self.id).joins(:visits).select([:organization_id])
    Organization.where(id: id).select([:name]).first
  end
end
