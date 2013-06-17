class MapController < ApplicationController
  def index
  end

  def location_list
    location = Location.order("created_at DESC").to_json(
      :only => [:lat, :lon, :id],
      :methods => [
        :location_urls,
        :organization
      ]
    )
    render json: location
  end

  def city_list
    city = City.order("created_at DESC").to_json(
      :only => [:lat, :lon, :id, :name],
      :methods => [
         :city_urls
      ]
    )
    render json: city
  end

  def country_list
    country = CountryLocation.order("iso2 ASC").to_json(
      :only => [:lat, :lon, :iso2, :name, :id],
      :methods => [
         :country_urls
      ]
    )
    render json: country
  end


end
