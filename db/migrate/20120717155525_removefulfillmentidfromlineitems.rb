class Removefulfillmentidfromlineitems < ActiveRecord::Migration
  def up
    remove_column :line_items, :fulfillment_id
  end

  def down
    add_column :line_items,:fulfillment_id, :integer
  end
end
