class CreateCountryLocations < ActiveRecord::Migration
  def change
    create_table :country_locations do |t|
      t.float :lat
      t.float :lon
      t.string :iso2

      t.timestamps
    end
  end
end
