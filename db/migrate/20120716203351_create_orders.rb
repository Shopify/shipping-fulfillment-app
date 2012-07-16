class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer  :shopify_order_id
      t.integer  :shipping_address_id
      t.string   :email
      t.integer  :number
      t.datetime :deleted_at
      t.integer  :total_weight
      t.string   :currency
      t.string   :financial_status
      t.boolean  :confirmed, :default => false
      t.string   :fulfillment_status
      t.string   :name
      t.datetime :cancelled_at
      t.string   :cancel_reason
      t.decimal  :total_price

      t.timestamps
    end
  end
end
