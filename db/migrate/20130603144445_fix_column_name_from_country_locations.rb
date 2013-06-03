class FixColumnNameFromCountryLocations < ActiveRecord::Migration
  def up
    rename_column :country_locations, :country_name, :name
  end

  def down
    rename_column :country_locations, :name, :country_name
  end
end
