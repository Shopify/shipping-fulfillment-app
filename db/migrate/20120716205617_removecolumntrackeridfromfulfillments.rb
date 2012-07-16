class Removecolumntrackeridfromfulfillments < ActiveRecord::Migration
  def up
    remove_column :fulfillments, :tracker_id
  end

  def down
    add_column :fulfillments, :tracker_id, :integer
  end
end
