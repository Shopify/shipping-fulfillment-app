class CreateFulfillmentLineItems < ActiveRecord::Migration
  def change
    create_table :fulfillment_line_items do |t|
      t.integer :line_item_id
      t.integer :fulfillment_id
      t.timestamps
    end
  end
end
