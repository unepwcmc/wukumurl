class City < ActiveRecord::Base
  attr_accessible :country, :iso2, :iso3, :lat, :lon, :name, :region
  has_many :visits

  MaxMindMappings = {country_name: :country, country_code: :iso2, country_code3: :iso3, latitude: :city_lat, longitude: :city_lon, city: :city_name, region: :region}

  def self.find_or_create_by_max_mind_attributes attributes
      short_attributes = attributes.slice(:country_name, :country_code, :latitude, :longitude, :region, :city)
    # Map max mind names to model names
      short_attributes = Hash[short_attributes.map {|k, v| [MaxMindMappings[k], v] }]
      city = City.where(short_attributes).first || City.create(short_attributes)
  end

end
