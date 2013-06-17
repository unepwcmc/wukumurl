class AddLocationSourceToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :location_source, :string
  end
end
