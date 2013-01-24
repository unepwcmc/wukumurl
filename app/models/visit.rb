class Visit < ActiveRecord::Base
  attr_accessible :ip_address, :short_url_id

  belongs_to :short_url
  belongs_to :country

  def geo_locate
    require 'geoip'
    cdb = GeoIP::Country.new(GEO_IP_CONFIG['country_db'])
    country_attributes = cdb.look_up self.ip_address
    if country_attributes.nil?
      puts "Unable to geolocate visit #{self.id}"
    else
      self.country = Country.find_or_create_by_max_mind_attributes country_attributes
    end
  end

  def self.un_geolocated
    self.where(country_id: nil)
  end
end
