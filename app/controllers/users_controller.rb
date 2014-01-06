class UsersController < ApplicationController
  def show
    @visits_by_country = current_user.visits_by_country
    @visits_by_organization = current_user.visits_by_organization

    @total_visits = current_user.visits.length

    @short_urls = current_user.short_urls.
      ordered_by_visits_desc.
      order('created_at DESC')
  end
end
