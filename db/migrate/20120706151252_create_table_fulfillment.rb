class CreateTableFulfillment < ActiveRecord::Migration
  def change
    create_table :fulfillments do |t|
      t.text :line_items
      t.text :address
      t.integer :shopify_order_id
      t.string :shipwire_order_id
      t.string :message
      t.string :email
      t.string :shipping_method
      t.string :status
      t.integer :setting_id
      t.timestamps
    end
    add_index :fulfillments, :setting_id
  end
end