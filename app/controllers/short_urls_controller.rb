class ShortUrlsController < ApplicationController
  def create
    if params[:url].present?
      short_url = ShortUrl.new(
        url: params[:url],
        short_name: params[:short_name]
      )
      if short_url.save
        render json: short_url, status: :created
      else
        render json: short_url.errors, status: :unprocessable_entity
      end
    else
      render json: {error: "You must specify a url parameter to redirect to"}, status: :unprocessable_entity
    end
  end

  def visit
    short_url = ShortUrl.find_by_short_name(params[:short_name])
    if short_url
      visit = Visit.create(short_url_id: short_url.id, ip_address: request.remote_ip)
      redirect_to short_url.url
    else
      @short_urls = ShortUrl.not_deleted.order("created_at DESC")
    end
  end

  def show
    @short_url = ShortUrl.find(params[:id])
    @visits = @short_url.visit_count
    @visits_by_country = @short_url.visits_by_country
    @visits_by_organization = @short_url.visits_by_organization
  end

  def destroy
    @short_url = ShortUrl.find(params[:id])
    @short_url.deleted = true
    @short_url.save
    redirect_to :action => "visit"
  end
end
