class Renamesettingtoshop < ActiveRecord::Migration
  def change
    remove_index :variants, :name => :index_synced_variants_on_setting_id
    remove_index :fulfillments, :setting_id
    remove_column :fulfillments, :setting_id
    remove_column :variants, :setting_id
    remove_column :orders, :setting_id
    add_column :fulfillments, :shop_id, :integer
    add_column :variants, :shop_id, :integer
    add_column :orders, :shop_id, :integer
  end
end
