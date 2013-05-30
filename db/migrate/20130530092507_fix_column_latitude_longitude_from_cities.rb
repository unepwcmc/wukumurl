class FixColumnLatitudeLongitudeFromCities < ActiveRecord::Migration
  def up
    rename_column :cities, :latitude, :lat
    rename_column :cities, :longitude, :lon
  end

  def down
    rename_column :cities, :lat, :latitude
    rename_column :cities, :lon, :longitude
  end
end
