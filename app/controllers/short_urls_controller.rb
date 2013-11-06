class ShortUrlsController < ApplicationController

  before_filter :authenticate_user!, :only => [:update]

  def index
    @short_urls = ShortUrl.
      ordered_by_visits_desc.
      not_deleted
  end

  def create
    if params[:url].present?
      short_url = ShortUrl.new(
        url: params[:url],
        short_name: params[:short_name],
        not_a_robot: params[:not_a_robot] == "true",
        user: current_user
      )

      if short_url.save
        render json: short_url, status: :created
      else
        render json: short_url.errors, status: :unprocessable_entity
      end
    else
      render json: {
        url_to_shorten: "You must specify a url parameter to redirect to"
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
    if params[:short_name].present?
      @short_url = ShortUrl.where(short_name: params[:short_name]).first
    elsif params[:id].present?
      @short_url = ShortUrl.find(params[:id])
    end

    return redirect_to :root unless @short_url

    @url_belongs_to_user = @short_url.does_url_belong_to_user? current_user
    @visits = @short_url.visit_count
    @visits_by_country = @short_url.visits_by_country
    @visits_by_organization = @short_url.visits_by_organization
  end

  def destroy
    short_url = ShortUrl.find(params[:id])
    short_url.deleted = true
    short_url.save
    redirect_to :root
  end

  def update
    short_url = ShortUrl.find(params[:id])
    short_name = params[:short_url][:short_name]
    short_url.short_name = short_name
    short_url.save
    redirect_to :action => "show", :short_name => short_name
  end
end
