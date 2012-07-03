class CreateSyncedVariants < ActiveRecord::Migration
  def change
    create_table :synced_variants do |t|
      t.integer :variant_id
      t.integer :setting_id
      t.integer :inventory
      t.timestamps
    end
    add_index :synced_variants, :setting_id
  end
end
