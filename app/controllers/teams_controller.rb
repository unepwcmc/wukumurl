class TeamsController < ApplicationController
  # Responsible for showing an individual team, like "/team/informatics"
  def show
    @team = Team.friendly.find(params[:id])

    @number_of_visits = @team.total_visits.length
    @unique_visits = @team.total_visits.uniq {|v| v.ip_address }.count
    @number_of_links_shared = @team.short_urls.count
    @countries_reached = @team.visits_by_country.length

    # Remove these
    @visits_by_country = @team.visits_by_country
    @visits_by_country_count = @visits_by_country.length
    @visits_by_organization = @team.all_visits_by_organization
    @visits_by_organization_count = @visits_by_organization.length

    @total_visits = @team.total_visits.length
    @total_urls   = @team.total_urls

    @short_urls = @team.short_urls.ordered_by_visits_desc.not_deleted

    @top_10_visits_by_country = @team.visits_by_country.sort_by{|k,v| v}.reverse.first(10)
  end
end
