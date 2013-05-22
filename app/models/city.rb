class City < ActiveRecord::Base
  attr_accessible :country, :iso2, :iso3, :latitude, :longitude, :name, :region
end
