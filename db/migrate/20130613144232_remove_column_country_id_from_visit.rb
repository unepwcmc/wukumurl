class RemoveColumnCountryIdFromVisit < ActiveRecord::Migration
  def up
    remove_column :visits, :country_id
  end

  def down
    add_column :visits, :country_id, :integer
  end
end
