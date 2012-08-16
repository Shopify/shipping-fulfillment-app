class MergeShippingAddressIntoOrders < ActiveRecord::Migration
  def change
    drop_table :shipping_addresses
    add_column :orders, :address1, :string
    add_column :orders, :address2, :string
    add_column :orders, :city, :string
    add_column :orders, :zip, :string
    add_column :orders, :province, :string
    add_column :orders, :country, :string
    add_column :orders, :latitude, :decimal, :precision => 9, :scale => 6
    add_column :orders, :longitude, :decimal, :precision => 9, :scale => 6
  end
end
