class UsersController < ApplicationController
  def show
    @visits_by_country = current_user.visits_by_country
    @visits_by_country_count = @visits_by_country.count
    @visits_by_organization = current_user.visits_by_organization
    @visits_by_organization_count = @visits_by_organization.count

    @total_visits = current_user.visits.length

    @short_urls = current_user.short_urls.
      with_visits.
      order('created_at DESC')
  end
end
