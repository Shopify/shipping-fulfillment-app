class CreateFulfillments < ActiveRecord::Migration
  def change
    create_table :fulfillments do |t|
      t.text :line_items
      t.text :address
      t.integer :order_id
      t.string :message
      t.string :email
      t.string :shipping_method
      t.string :tracking_number
      t.string :status
      t.timestamps
    end
  end
end