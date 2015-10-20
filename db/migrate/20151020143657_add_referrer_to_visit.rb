class AddReferrerToVisit < ActiveRecord::Migration
  def change
    add_column :visits, :referrer, :string
  end
end
