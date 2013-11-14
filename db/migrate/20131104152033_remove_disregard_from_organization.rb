class RemoveDisregardFromOrganization < ActiveRecord::Migration
  def change
    remove_column :organizations, :disregard
  end
end
