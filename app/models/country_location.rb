class CountryLocation < ActiveRecord::Base
  has_many :city, :foreign_key => "iso2", :primary_key => "iso2"
  has_many :short_urls, :through => :city

  def country_urls
    CountryLocation.where(iso2: self.iso2).joins(:short_urls).select([:short_name, :url, :country]).where("cities.iso2 IS NOT NULL")
  end
end
