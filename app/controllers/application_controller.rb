class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
    def authenticate_admin 
      redirect_to root_path, notice: "You do not have permission to access that page" unless current_user && current_user.admin?
    end
end
