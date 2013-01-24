class AddCountryAssociationToVisit < ActiveRecord::Migration
  def change
    add_column :visits, :country_id, :integer
  end
end
