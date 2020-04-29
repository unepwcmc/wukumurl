class AddOrganizationAssociationToVisit < ActiveRecord::Migration
  def change
    add_column :visits, :organization_id, :integer
  end
end
