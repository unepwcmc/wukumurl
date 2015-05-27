class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def authenticate_admin
    unless current_user && current_user.admin?
      redirect_to root_path, notice: "You do not have permission to access that page"
    end
  end

  def dont_show_map
    @no_map = true
  end
end
