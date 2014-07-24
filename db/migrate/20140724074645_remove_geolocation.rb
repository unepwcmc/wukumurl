class RemoveGeolocation < ActiveRecord::Migration
  def change
    drop_table :locations
    drop_table :cities
    drop_table :country_locations
    drop_table :organizations
    remove_column :visits, :city_id
    remove_column :visits, :organization_id
    remove_column :visits, :location_id
  end
end
