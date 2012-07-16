class CreateShippingAddresses < ActiveRecord::Migration
  def change
    create_table :shipping_addresses do |t|
      t.integer :shop_id
      t.string :address1
      t.string :address2
      t.string :city
      t.string :zip
      t.string :province
      t.string :country

      t.timestamps
    end
  end
end
