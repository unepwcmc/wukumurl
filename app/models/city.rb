class City < ActiveRecord::Base
  has_many :visits
  has_many :short_urls, :through => :visits
  belongs_to :country_location, :foreign_key => "iso2", :primary_key => "id"

  MaxMindMappings = {country_name: :country, country_code: :iso2, country_code3: :iso3, latitude: :lat, longitude: :lon, city: :name, region: :region}

  def self.find_or_create_by_max_mind_attributes attributes
    short_attributes = attributes.slice(:country_name, :country_code, :latitude, :longitude, :region, :city)
    # Map max mind names to model names
    short_attributes = Hash[short_attributes.map {|k, v| [MaxMindMappings[k], v] }]
    City.where(short_attributes).first || City.create(short_attributes)
  end

  def self.all_visits_by_country
    joins(:visits).group(:country).count
  end

  def city_urls
    City.where(id: self.id).joins(:short_urls).select([:short_name, :url])
  end
end
