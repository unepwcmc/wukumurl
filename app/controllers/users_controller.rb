class UsersController < ApplicationController
  def show
    return redirect_to :root unless current_user
    @short_urls = current_user.short_urls.ordered_by_visits_desc
  end
end
