class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_paper_trail_whodunnit

  def user_for_paper_trail
    user_signed_in? ? current_user.email : "Admin"
  end

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
