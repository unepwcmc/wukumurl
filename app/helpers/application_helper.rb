module ApplicationHelper
  def back_button
    if controller.controller_name == 'short_urls' &&
      controller.action_name == 'show'
      return link_to(
        '<i class="fa fa-chevron-circle-left"></i>'.html_safe,
        "/",
        class: 'back'
      )
    end
  end

  def title page_title
    content_for :title, page_title.html_safe
  end

  ### Devise

  def user_input_has_error? field_name
    if flash[:errors] && flash[:errors][:user]
      return !flash[:errors][:user][field_name].blank?
    end

    return false
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
