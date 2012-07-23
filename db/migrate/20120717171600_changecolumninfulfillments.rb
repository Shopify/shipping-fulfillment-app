class Changecolumninfulfillments < ActiveRecord::Migration
  def up
    remove_column :fulfillments, :shopify_order_id
    add_column :fulfillments, :order_id, :integer
  end

  def down
    remove_column :fulfillments, :order_id
    add_column :fulfillments, :shopify_order_id, :integer
  end
end
