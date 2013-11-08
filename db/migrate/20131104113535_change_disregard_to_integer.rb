class ChangeDisregardToInteger < ActiveRecord::Migration
  def change
    change_column :organizations, :disregard, 'integer USING CAST(disregard AS integer)', :default => 0
  end
end
