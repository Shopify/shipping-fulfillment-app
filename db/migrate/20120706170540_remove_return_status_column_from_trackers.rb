class RemoveReturnStatusColumnFromTrackers < ActiveRecord::Migration
  def change
    remove_column :trackers, :returned_status
  end
end
