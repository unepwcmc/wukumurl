class ShortUrlsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :update, :destroy]

  def index
    @visits = Visit.all
    @total_visits = Visit.count
    @total_urls   = ShortUrl.not_deleted.count

    @short_urls = ShortUrl.
      ordered_by_visits_desc.
      not_deleted
  end

  def list
    return redirect_to :root unless user_signed_in?

    @short_urls = current_user.short_urls.
      with_visits.
      order('created_at DESC').
      not_deleted

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
      Visit.create(
        short_url_id: short_url.id,
        ip_address: request.remote_ip,
        domain: request.domain
      )
    end

    redirect_to short_url.url
  end

  def show
    @short_url = ShortUrl.where(short_name: params[:short_name]).first
    return redirect_to :root unless @short_url

    @url_belongs_to_user = @short_url.owned_by? current_user
    @total_visits = @short_url.visit_count
  end

  def destroy
    short_url = ShortUrl.find(params[:id])

    if short_url.user == current_user
      short_url.destroy
    end

    redirect_to :root
  end

  def update
    short_url = ShortUrl.find(params[:id])

    return redirect_to :root unless short_url.user == current_user

    if short_url.update_attributes(short_url_params)
      render json: short_url
    else
      render json: short_url.errors, status: :unprocessable_entity
    end
  end

  private

  def short_url_params
    params.require(:short_url).permit(:url, :short_name)
  end
end
