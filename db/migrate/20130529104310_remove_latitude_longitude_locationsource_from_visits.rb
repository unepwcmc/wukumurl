class RemoveLatitudeLongitudeLocationsourceFromVisits < ActiveRecord::Migration
  def up
    remove_column :visits, :latitude
    remove_column :visits, :longitude
    remove_column :visits, :location_source
  end

  def down
    add_column :visits, :location_source, :string
    add_column :visits, :longitude, :float
    add_column :visits, :latitude, :float
  end
end
