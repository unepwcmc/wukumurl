class ShortUrlsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :edit, :update, :destroy]
  #before_filter :authenticate_admin, :only => [:edit]

  def index
    @visits_by_country = City.all_visits_by_country
    @visits_by_country_count = @visits_by_country.length
    @visits_by_organization = Organization.all_visits_by_organization(10)
    @visits_by_organization_count = @visits_by_organization.length
    @visits_by_team = Team.visits_by_team
    @visits_by_team_count = @visits_by_team.length

    @number_of_visits = Visit.count
    @unique_visits = Visit.select("DISTINCT ip_address").count
    @number_of_links_shared = ShortUrl.not_deleted.count

    @short_urls = ShortUrl.
      ordered_by_visits_desc.
      not_deleted

    @line_graph_hash = Team.multiline_visits_graph
    @top_referrals = Visit.top_referrals
    @top_10_visits_by_country = @visits_by_country.sort_by{|k,v| v}.reverse.first(10)
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
    if params[:short_url].present?
      short_url = ShortUrl.new(short_url_params)
      short_url.user = current_user

      if short_url.save
        redirect_to user_links_path(short_name: short_url.short_name), notice: "Link created successfully!"
      else
        redirect_to user_links_path, alert: "There was a problem creating your link, please try again"
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
      visit = Visit.create(
        short_url_id: short_url.id,
        ip_address: request.remote_ip,
        domain: request.domain,
        referrer: (request.referrer.blank? ? nil : URI(request.referrer).host)
      )
      GeoLocator.perform_async(visit.id)
    end

    redirect_to short_url.url
  end

  def show
    @short_url = ShortUrl.where(short_name: params[:short_name]).first
    return redirect_to :root unless @short_url

    @url_belongs_to_user = @short_url.owned_by? current_user
    @total_visits = @short_url.visit_count
    @unique_visits = @short_url.visits.uniq { |v| v.ip_address }.count
    @visits_by_country = @short_url.visits_by_country
    @visits_by_country_count = @visits_by_country.length
    @visits_by_organization = @short_url.visits_by_organization group_by_disregarded: false
    @visits_by_organization_count = @visits_by_organization.length
    @top_referrals = @short_url.top_referrals
    @top_10_visits_by_country = @visits_by_country.sort_by{|k,v| v}.reverse.first(10)
  end

  def destroy
    short_url = ShortUrl.find(params[:id])

    short_url.destroy if current_user.can_manage?(short_url)
    redirect_to :root, notice: "Link deleted successfully"
  end

  def edit
    @short_url = ShortUrl.find(params[:id])
  end

  def update
    short_url = ShortUrl.find(params[:id])

    unless current_user.can_manage?(short_url)
      return redirect_to :root, notice: "You do not have permission to manage that link"
    end

    if short_url.update_attributes(short_url_params)
      redirect_to short_url, notice: "Link updated successfully"
    else
      redirect_to short_url, notice: "There was a problem updating your link"
    end
  end

  def organizations_table
    @short_url = ShortUrl.where(short_name: params[:short_name]).first
    @visits_by_organization = @short_url.visits_by_organization group_by_disregarded: false
    @visits_by_organization_count = @visits_by_organization.length

    render partial: "organizations_table", locals: {title: "Top organisations by number of visits"}
  end

  private

  def short_url_params
    params.require(:short_url).permit(:url, :short_name, :private, :description, :user_id)
  end
end
