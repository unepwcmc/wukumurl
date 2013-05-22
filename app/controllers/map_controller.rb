class MapController < ApplicationController
  def index
  end

  def list
      short_urls = ShortUrl.not_deleted.order("created_at DESC").to_json(
        :only => [:id, :short_name, :url],
        :methods => [
          :visit_count, 
          :visits_id
        ]
      )
      render json: short_urls
  end

end
