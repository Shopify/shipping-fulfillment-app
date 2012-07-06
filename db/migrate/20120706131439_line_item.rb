class LineItem < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :fulfillment_id, :null => false
      t.string :fulfillment_service
      t.string :fulfillment_status
      t.integer :grams
      t.integer :line_item_id
      t.string :price
      t.integer :product_id, :null => false
      t.integer :quantity
      t.string :requires_shipping
      t.string :sku
      t.string :title
      t.integer :variant_id, :null => false
      t.string :variant_title
      t.string :vendor
      t.string :name
      t.string :variant_inventory_management
      t.timestamps
    end
  end
end