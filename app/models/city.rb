class City < ActiveRecord::Base
  attr_accessible :country, :iso2, :iso3, :latitude, :longitude, :name, :region
  has_many :visits

  MaxMindMappings = {country_name: :country, country_code: :iso2, country_code3: :iso3, latitude: :latitude, longitude: :longitude, city: :name}

  def self.find_or_create_by_max_mind_attributes attributes
      new_attributes = attributes.slice(:country_name,:country_code,:latitude,:longitude,:city)
    # Map max mind names to model names
      new_attributes = Hash[new_attributes.map {|k, v| [MaxMindMappings[k], v] }]
      city = City.where(new_attributes).first || City.create(new_attributes)
  end

end
