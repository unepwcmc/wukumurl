class StaticPagesController < ApplicationController
  def index
    @visits_by_country = City.all_visits_by_country
    @visits_by_country_count = @visits_by_country.length
    @visits_by_organization = Organization.all_visits_by_organization
    @visits_by_organization_count = @visits_by_organization.length
    @visits_by_team = Team.visits_by_team
    @visits_by_team_count = @visits_by_team.length

    @number_of_visits = Visit.count
    @unique_visits = Visit.select('DISTINCT ip_address').count
    @number_of_links_shared = ShortUrl.not_deleted.count

    @short_urls = ShortUrl.
      ordered_by_visits_desc.
      not_deleted
  end
end
