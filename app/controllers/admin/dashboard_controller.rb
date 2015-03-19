class Admin::DashboardController < ApplicationController
  before_filter :authenticate_admin
  layout 'admin'

  def index
    @short_urls = ShortUrl.all
  end
end