class City < ActiveRecord::Base
  attr_accessible :country, :iso2, :iso3, :latitude, :longitude, :name, :region
  has_many :visits

    MaxMindMappings = {country_name: :country, country_code: :iso2, country_code3: :iso3, latitude: :latidude, longitude: :longitude, city: :name, region_name: :region}

  def self.find_or_create_by_max_mind_attributes attributes
    # Map max mind names to model names
    attributes = Hash[attributes.map {|k, v| [MaxMindMappings[k], v] }]

    city = City.where(attributes).first || City.create(attributes)
  end

end
