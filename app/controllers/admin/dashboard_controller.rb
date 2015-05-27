class Admin::DashboardController < ApplicationController
  before_filter :authenticate_admin
  before_filter :dont_show_map

  def index
    @short_urls = ShortUrl.all
  end
end