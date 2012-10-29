class DropOrderAndVariantTables < ActiveRecord::Migration
  def change
    drop_table :orders
    drop_table :variants
  end
end
