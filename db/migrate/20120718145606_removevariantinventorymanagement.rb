class Removevariantinventorymanagement < ActiveRecord::Migration
  def change
    remove_column :line_items, :variant_inventory_management
  end
end
