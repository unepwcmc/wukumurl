class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource sign_up_params

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        redirect_to :back
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        redirect_to :back
      end
    else
      failure
    end
  end

  def failure
    clean_up_passwords resource

    flash[:errors] ||= {}
    flash[:errors][:registration] = "Some errors occurred while trying to sign you up"

    flash[:errors][:user] = resource.errors.messages

    return redirect_to :back
  end
end
