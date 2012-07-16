class Addwarehousetofulfillment < ActiveRecord::Migration
  def change
    add_column :fulfillments, :warehouse, :string 
    add_column :fulfillments, :tracker_id, :integer
  end
end
