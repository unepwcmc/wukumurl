class AddDescriptionToShortUrlsTable < ActiveRecord::Migration
  def change
    add_column :short_urls, :description, :text
  end
end
