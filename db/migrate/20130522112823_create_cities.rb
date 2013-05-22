class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :iso2
      t.string :iso3
      t.string :country
      t.string :region
      t.string :name
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
