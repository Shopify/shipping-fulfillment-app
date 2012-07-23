class RemovecolumnshippingAddressIdfromorder < ActiveRecord::Migration
  def up
    remove_column :orders, :shipping_address_id
  end

  def down
    add_column :orders, :shipping_address_id, :integer
  end
end
