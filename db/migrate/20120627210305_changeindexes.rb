class Changeindexes < ActiveRecord::Migration
  def up
    add_column :fulfillments, :setting_id, :integer
    add_index :fulfillments, :setting_id
  end

  def down
    remove_index :fulfillments, :setting_id
    remove_column :fulfillments, :setting_id, :integer
  end
end
