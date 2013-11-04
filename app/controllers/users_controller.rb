class UsersController < ApplicationController
  def show
    user = User.find(params[:id])

    @short_urls = user.short_urls
  end
end
