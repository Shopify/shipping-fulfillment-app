class RemovecolumnshopIdfromshippingaddresses < ActiveRecord::Migration
  def up
    remove_column :shipping_addresses, :shop_id
  end

  def down
    add_column :shipping_address, :shop_id, :integer
  end
end
