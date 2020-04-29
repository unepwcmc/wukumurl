class AddCountryNameToCountryLocation < ActiveRecord::Migration
  def change
    add_column :country_locations, :country_name, :string
  end
end
