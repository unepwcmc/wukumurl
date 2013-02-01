class AddSoftDeleteBoolToShortUrl < ActiveRecord::Migration
  def change
    add_column :short_urls, :deleted, :boolean
  end
end
