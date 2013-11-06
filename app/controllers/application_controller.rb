class ApplicationController < ActionController::Base
  protect_from_forgery

  def user_required
    unless current_user
      redirect_to root_url
    end
  end
end
