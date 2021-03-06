class TeamsController < ApplicationController
  # Responsible for showing an individual team, like "/team/informatics"
  def show
    @team = Team.friendly.find(params[:id])

    @visits_by_country = @team.visits_by_country
    @visits_by_country_count = @visits_by_country.length
    @visits_by_organization = @team.all_visits_by_organization
    @visits_by_organization_count = @visits_by_organization.length

    @total_visits = @team.total_visits.length
    @total_urls   = @team.total_urls

    @short_urls = @team.short_urls.ordered_by_visits_desc.not_deleted
  end
end
