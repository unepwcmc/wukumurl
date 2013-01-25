class Visit < ActiveRecord::Base
  attr_accessible :ip_address, :short_url_id

  belongs_to :short_url
  belongs_to :country
  belongs_to :organization

  def geo_locate
    require 'geoip'
    geo_locate_country
    geo_locate_organization
  end

  def geo_locate_country
    cdb = GeoIP::Country.new(GEO_IP_CONFIG['country_db'])
    country_attributes = cdb.look_up self.ip_address
    if country_attributes.nil?
      puts "Unable to geolocate country of visit #{self.id}"
    else
      self.country = Country.find_or_create_by_max_mind_attributes country_attributes
    end
  end

  def geo_locate_organization
    cdb = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])
    organization_attributes = cdb.look_up self.ip_address
    if organization_attributes.nil?
      puts "Unable to geolocate organisation of visit #{self.id}"
    else
      self.organization = Organization.find_or_create_by_max_mind_attributes organization_attributes
    end
  end

  def self.un_geolocated
    self.where(country_id: nil)
  end
end
