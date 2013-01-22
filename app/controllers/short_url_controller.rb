class ShortUrlController < ApplicationController
  def create
    puts params
    if params[:url].present?
      short_url = ShortUrl.new(
        url: params[:url],
        short_name: params[:short_name]
      )
      if short_url.save
        render json: short_url, status: :created
      else
        render json: short_url.errors, status: :unprocessable_entity
      end
    else
      render json: {error: "You must specify a url parameter to redirect to"}, status: :unprocessable_entity
    end
  end

  def visit
    short_url = ShortUrl.find_by_short_name(params[:short_name])
    if short_url
      redirect_to short_url.url
    else
    end
  end

  def show
  end
end
