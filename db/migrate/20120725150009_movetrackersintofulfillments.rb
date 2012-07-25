class Movetrackersintofulfillments < ActiveRecord::Migration
  def up
    drop_table :trackers
    add_column :fulfillments, :tracking_carrier, :string
    add_column :fulfillments, :tracking_link, :string
    add_column :fulfillments, :tracking_number, :integer
    add_column :fulfillments, :ship_date, :datetime
    add_column :fulfillments, :expected_delivery_date, :datetime
    add_column :fulfillments, :return_date, :datetime
    add_column :fulfillments, :return_condition, :string
    add_column :fulfillments, :shipper_name, :string
    add_column :fulfillments, :total, :string
    add_column :fulfillments, :returned, :string
    add_column :fulfillments, :shipped, :string
    add_column :fulfillments, :fulfillment_id, :integer
    add_column :fulfillments, :shipwire_order_id, :string
  end
end
