class AddDisregardToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :disregard, :boolean
  end
end
