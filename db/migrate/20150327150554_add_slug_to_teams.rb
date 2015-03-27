class AddSlugToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :slug, :string
    add_index :teams, :slug
  end
end
