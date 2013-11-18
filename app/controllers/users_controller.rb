class UsersController < ApplicationController
  def show
    @visits_by_country = City.
      select("country, count(*) as value").
      joins(:visits).
      group(:country).
      order('value desc')

    @visits_by_organization = Organization.
      select("name, count(*) as visit_count").
      joins(:visits).
      group(:name).
      order('visit_count desc')

    @total_visits = current_user.visits.length

    @short_urls = current_user.
      short_urls.
      ordered_by_visits_desc.
      not_deleted

    @no_urls_yet = current_user.no_urls?
  end
end
