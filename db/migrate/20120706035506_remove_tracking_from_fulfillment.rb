class RemoveTrackingFromFulfillment < ActiveRecord::Migration
  def up
    remove_column :fulfillments, :tracking_number
  end

  def down
    add_column :fulfillments, :tracking_number, :string
  end
end
