class LineItemNowBelongsToShop < ActiveRecord::Migration
  def change
    add_column :line_items, :shop_id, :integer
  end
end
