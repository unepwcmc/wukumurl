class DropUrlsLocation < ActiveRecord::Migration
  def change
    drop_table :url_locations
  end
end
