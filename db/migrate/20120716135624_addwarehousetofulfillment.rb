class Addwarehousetofulfillment < ActiveRecord::Migration
  def change
    add_column :fulfillments, :warehouse, :string 
  end
end
