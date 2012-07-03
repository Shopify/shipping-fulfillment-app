class Addactivatedcolumntovariant < ActiveRecord::Migration
  def up
    add_column :variants, :activated, :boolean
  end

  def down
    remove_column :variants, :activated
  end
end
