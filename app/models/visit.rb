class Visit < ActiveRecord::Base
  attr_accessible :ip_address, :short_url_id

  belongs_to :short_url
  belongs_to :country
  belongs_to :organization

  # Pass in GeoIP database instances separately, as creating an instance
  # per Visit results in a memory leak.
  def geo_locate country_db, organisation_db
    geo_locate_country(country_db)
    geo_locate_organization(organisation_db)
  end

  def geo_locate_country db
    country_attributes = db.look_up self.ip_address
    if country_attributes.nil?
      # Too noisy for now
      #puts "Unable to geolocate country of visit #{self.id}"
    else
      self.country = Country.find_or_create_by_max_mind_attributes country_attributes
    end
  end

  def geo_locate_organization db
    organization_attributes = db.look_up self.ip_address
    if organization_attributes.nil?
      # Too noisy for now
      #puts "Unable to geolocate organisation of visit #{self.id}"
    else
      self.organization = Organization.find_or_create_by_max_mind_attributes organization_attributes
    end
  end

  def self.un_geolocated
    self.where(country_id: nil)
  end
end
