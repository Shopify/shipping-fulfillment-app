class Removetrackerindex < ActiveRecord::Migration
  def up
    remove_index :trackers, :column => :fulfillment_id
  end

  def down
    add_index :trackers, :column => :fulfillment_id
  end
end
