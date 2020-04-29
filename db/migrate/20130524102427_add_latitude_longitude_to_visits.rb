class AddLatitudeLongitudeToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :latitude, :float
    add_column :visits, :longitude, :float
  end
end
