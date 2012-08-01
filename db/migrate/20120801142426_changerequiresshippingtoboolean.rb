class Changerequiresshippingtoboolean < ActiveRecord::Migration
  def change
    remove_column :line_items, :requires_shipping
    add_column :line_items, :requires_shipping, :boolean
  end
end
