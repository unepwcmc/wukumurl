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
    content_for :title, page_title.to_s
  end

  ### Devise

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
