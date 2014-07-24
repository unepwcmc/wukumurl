class UsersController < ApplicationController
  def show
    @visits = current_user.visits
    @total_visits = current_user.visits.length

    @short_urls = current_user.short_urls.
      with_visits.
      order('created_at DESC').
      not_deleted
  end
end
