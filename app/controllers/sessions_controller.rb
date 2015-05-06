class SessionsController < Devise::SessionsController
  layout false

  def create
    resource = warden.authenticate!(
      :scope => resource_name,
      :recall => "#{controller_path}#failure"
    )

    sign_in_and_redirect(resource_name, resource)
  end

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    redirect_to (request.referrer == root_url ? user_links_path : :back)
  end

  def failure
    flash[:errors] ||= {}
    flash[:errors][:session] = "Incorrect username or password"

    return redirect_to :back
  end

  def hide_info_modal
    session[:hide_info_modal] = true
    redirect_to root_path
  end
end
