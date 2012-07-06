class CleanUpFulfillment < ActiveRecord::Migration
  def change
    remove_column :fulfillments, :message
    remove_column :fulfillments, :line_items
  end
end
