class CreateUrlLocations < ActiveRecord::Migration
  def change
    create_table :url_locations do |t|

      t.timestamps
    end
  end
end
