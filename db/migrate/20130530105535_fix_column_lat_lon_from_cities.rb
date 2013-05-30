class FixColumnLatLonFromCities < ActiveRecord::Migration
  def up
    rename_column :cities, :lat, :city_lat
    rename_column :cities, :lon, :city_lon
    rename_column :cities, :name, :city_name
  end

  def down
    rename_column :cities, :city_lat, :lat
    rename_column :cities, :city_lon, :lon
    rename_column :cities, :city_name, :name
  end

end
