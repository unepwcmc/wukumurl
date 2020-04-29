class AddPrivateBooleanToShortUrlsTable < ActiveRecord::Migration
  def change
    add_column :short_urls, :private, :boolean, default: false
  end
end
