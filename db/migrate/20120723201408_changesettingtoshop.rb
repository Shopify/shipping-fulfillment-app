class Changesettingtoshop < ActiveRecord::Migration
  def up
    rename_table :settings, :shops
  end

  def down
    rename_table :shops, :settings
  end
end
