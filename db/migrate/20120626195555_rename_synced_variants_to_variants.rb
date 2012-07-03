class RenameSyncedVariantsToVariants < ActiveRecord::Migration
  def up
    rename_table :synced_variants, :variants
  end

  def down
    rename_table :variants, :synced_variants
  end
end
