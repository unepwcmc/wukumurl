class AddCityIdToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :city_id, :integer
  end
end
