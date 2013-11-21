class ShortUrlsController < ApplicationController
  before_filter :authenticate_user!, :only => [:update]

  def index
    @visits_by_country = City.all_visits_by_country
    @visits_by_organization = Organization.all_visits_by_organization

    @total_visits = Visit.count
    @total_urls   = ShortUrl.count

    @short_urls = ShortUrl.
      not_deleted
  end

  def list
    return redirect_to :root unless user_signed_in?

    @short_urls = current_user.short_urls.not_deleted

    render "_short_urls_table", layout: false
  end

  def create
    if params[:url].present?
      short_url = ShortUrl.new(
        url: params[:url],
        short_name: params[:short_name],
        user: current_user
      )

      if short_url.save
        render json: short_url, status: :created
      else
        render json: short_url.errors, status: :unprocessable_entity
      end
    else
      render json: {
        url: "You must specify a url parameter to redirect to"
      }, status: :unprocessable_entity
    end
  end

  def visit
    short_url = ShortUrl.find_by(short_name: params[:short_name])
    return redirect_to :root unless short_url

    # Don't record stats for clicks via the link list on wcmc.io
    unless request.referrer =~ /#{root_url}(.*)/
      Visit.create(short_url_id: short_url.id, ip_address: request.remote_ip)
    end

    redirect_to short_url.url
  end

  def show
    @short_url = ShortUrl.where(short_name: params[:short_name]).first
    return redirect_to :root unless @short_url

    @url_belongs_to_user = @short_url.owned_by? current_user
    @total_visits = @short_url.visit_count
    @visits_by_country = @short_url.visits_by_country
    @visits_by_organization = @short_url.visits_by_organization group_by_disregarded: false
  end

  def destroy
    short_url = ShortUrl.find(params[:id])

    if short_url.destroy
      redirect_to :root
    end
  end

  def update
    short_url = ShortUrl.find(params[:id])

    if short_url.update_attributes(short_url_params)
      redirect_to :action => "show", :short_name => short_url.short_name
    else
      render json: short_url.errors, status: :unprocessable_entity
    end
  end

  private

  def short_url_params
    params.require(:short_url).permit(:url, :short_name)
  end
end
