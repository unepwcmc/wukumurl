class AddTeamIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :team_id, :integer
    add_foreign_key :users, :teams
  end
end
