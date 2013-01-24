class Country < ActiveRecord::Base
  attr_accessible :iso, :iso3, :name

  MaxMindMappings = {country_name: :name, country_code: :iso, country_code3: :iso3}

  def self.find_or_create_by_max_mind_attributes attributes
    # Map max mind names to model names
    attributes = Hash[attributes.map {|k, v| [MaxMindMappings[k], v] }]

    country = Country.where(attributes).first || Country.create(attributes)
  end
end
