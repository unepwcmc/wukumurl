class UsersController < ApplicationController
  def show
    @visits_by_country = City.select("country, count(*) as value")
      .joins(:visits).group(:country).order('value desc')
    @visits_by_organization = Organization.select("name, count(*) as value")
      .joins(:visits).group(:name).order('value desc')

    @total_visits = Visit.count
    @total_urls   = ShortUrl.count

    @short_urls = ShortUrl.
      where(user: current_user).
      ordered_by_visits_desc.
      not_deleted

    @no_urls_yet = current_user.no_urls_yet?
  end
end
