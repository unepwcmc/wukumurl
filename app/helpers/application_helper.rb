module ApplicationHelper
  def back_button
    if controller.controller_name == 'short_urls' &&
      controller.action_name == 'show'
      return link_to(
        '<i class="fa fa-chevron-circle-left"></i>'.html_safe,
        "/users/my_links",
        class: 'back'
      )
    elsif controller.controller_name == 'users' &&
      controller.action_name == 'show'
      return link_to(
        '<i class="fa fa-chevron-circle-left"></i>'.html_safe,
        "/",
        class: 'back user'
      )
    end
  end

  def title page_title=nil, &block
    if block_given?
      content_for :title, &block
    else
      content_for :title, page_title.html_safe
    end
  end

  def link_with_class_on_path title, path, class_name
    active_class = current_page?(path) ? class_name : ''
    link_to title, path, class: active_class
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
