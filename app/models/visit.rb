class Visit < ActiveRecord::Base
  attr_accessible :ip_address, :short_url_id, :short_name, :latitude, :longitude, :location_source

  belongs_to :short_url
  belongs_to :country
  belongs_to :organization
  belongs_to :city
  belongs_to :location

  require 'geoip'
  require 'geocoder'
=begin
  def geo_locate_country
    cdb = GeoIP::Country.new(GEO_IP_CONFIG['country_db'])
    country_attributes = cdb.look_up self.ip_address
    if country_attributes.nil?
      # Too noisy for now
      #puts "Unable to geolocate country of visit #{self.id}"
    else
      self.country = Country.find_or_create_by_max_mind_attributes country_attributes
    end
  end
=end

  def geo_locate
    #Look for Organization using IP
    orgdb = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])
    organization_attributes = orgdb.look_up self.ip_address

    #Look for City and Country using IP
    cdb = GeoIP::City.new(GEO_IP_CONFIG['city_db'])
    city_attributes = cdb.look_up self.ip_address
    puts city_attributes
    if city_attributes
      self.city = City.find_or_create_by_max_mind_attributes city_attributes
    end
    if organization_attributes.nil?
      self.location = Location.get_coordinates_using_geoip city_attributes
    else
      global_attributes = organization_attributes.merge(city_attributes)
      self.organization = Organization.find_or_create_by_max_mind_attributes organization_attributes
      self.location = Location.get_coordinates_using_geocoder global_attributes
    end
  end



  def self.un_geolocated
    self.where(city_id: nil)
  end
end
