class Addgeocodingtofulfillments < ActiveRecord::Migration
  def change
    add_column :fulfillments, :origin_lat, :decimal
    add_column :fulfillments, :origin_long, :decimal
    add_column :fulfillments, :destination_lat, :decimal
    add_column :fulfillments, :destination_long, :decimal
  end
end
