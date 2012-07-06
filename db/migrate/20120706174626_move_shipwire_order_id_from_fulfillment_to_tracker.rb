class MoveShipwireOrderIdFromFulfillmentToTracker < ActiveRecord::Migration
  def change
    add_column :trackers, :shipwire_order_id, :string
    remove_column :fulfillments, :shipwire_order_id
  end
end
