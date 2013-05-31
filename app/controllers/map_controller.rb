class MapController < ApplicationController
  def index
  end

  def location_list
    location = Location.order("created_at DESC").to_json(
      :only => [:lat, :lon, :id],
      :methods => [
        :location_urls
      ]
    )
    render json: location
  end

  def city_list
    city = City.order("created_at DESC").to_json(
      :only => [:lat, :lon, :id],
      :methods => [
         :city_urls
      ]
    )
    render json: city
  end


end
