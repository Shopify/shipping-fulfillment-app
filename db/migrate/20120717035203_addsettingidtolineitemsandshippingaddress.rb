class Addsettingidtolineitemsandshippingaddress < ActiveRecord::Migration
  def up
    add_column :shipping_addresses, :order_id, :integer
    add_column :line_items, :order_id, :integer
  end

  def down
    remove_column :line_items, :order_id
    remove_column :shipping_addresses, :order_id
  end
end
