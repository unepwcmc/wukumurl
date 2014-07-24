class RemoveDisregardVote < ActiveRecord::Migration
  def change
    drop_table :disregard_votes
  end
end
