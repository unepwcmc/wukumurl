class CompareController < ApplicationController
  def index
    url_ids = params[:tags].split("/").map { |s| s.to_i }
    
    puts url_ids
  end
end
