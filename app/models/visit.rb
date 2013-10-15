class Visit < ActiveRecord::Base
  attr_accessible :ip_address, :short_url_id, :short_name, :latitude,
    :longitude, :location_source

  belongs_to :short_url
  belongs_to :country
  belongs_to :organization
  belongs_to :city
  belongs_to :location

  def geo_locate (cdb, orgdb)
    #Look for Organization using IP
    organization_attributes = orgdb.look_up self.ip_address

    #Look for City and Country using IP
    city_attributes = cdb.look_up self.ip_address
    unless city_attributes.nil?
      self.city = City.find_or_create_by_max_mind_attributes city_attributes
      if organization_attributes.nil?
        self.location = Location.get_coordinates_using_geoip city_attributes
      else
        global_attributes = organization_attributes.merge(city_attributes)
        self.organization = Organization.find_or_create_by_max_mind_attributes organization_attributes
        self.location = Location.get_coordinates_using_geocoder global_attributes
      end
    end
  end

  def self.un_geolocated
    self.where(city_id: nil)
  end
end
