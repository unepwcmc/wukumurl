class CompareController < ApplicationController
  def index
    url_ids = params[:tags].split("/").map { |s| s.to_i }
    @urls = ShortUrl
      .where(:id => url_ids)
      .includes([:visits])
      .to_json(
        :only => [:id, :short_name, :url],
        :methods => [
          :visit_count, 
          :visits_today,
          :visits_this_week,
          :visits_this_month,
          :visits_by_country,
          :visits_by_organization
        ]
      )
    puts @urls
  end
end
