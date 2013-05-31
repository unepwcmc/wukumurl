class MapController < ApplicationController
  def index
  end

  def list
    location = Location.order("created_at DESC").to_json(
      :only => [:lat, :lon, :id],
      :methods => [
        :location_urls,
        :city_urls
      ]
    )
    render json: location
  end

end
