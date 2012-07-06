class CreateTrackers < ActiveRecord::Migration
  def change
    create_table :trackers do |t|
      t.string :tracking_carrier
      t.string :tracking_link
      t.integer :tracking_number
      t.datetime :ship_date
      t.datetime :expected_delivery_date
      t.datetime :return_date
      t.string :return_condition
      t.string :shipper_name
      t.string :total
      t.string :returned
      t.string :returned_status
      t.string :shipped
      t.integer :fulfillment_id
      t.timestamps
    end

    add_index :trackers, [:fulfillment_id]
  end
end
