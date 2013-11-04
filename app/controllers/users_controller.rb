class UsersController < ApplicationController
  def show
    return redirect_to :root unless current_user
    @short_urls = current_user.short_urls
  end
end
