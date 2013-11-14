class CreateDisregardVotes < ActiveRecord::Migration
  def change
    create_table :disregard_votes do |t|
      t.integer :short_url_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
