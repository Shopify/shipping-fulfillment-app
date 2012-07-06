class DropShipwireItems < ActiveRecord::Migration
  def change
    drop_table :shipwire_items
  end
end
