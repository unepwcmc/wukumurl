class RemoveCountryIdFromVisit < ActiveRecord::Migration
  def change
    remove_column :visits, :country_id
  end
end
