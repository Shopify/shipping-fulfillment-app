class Addskutovariant < ActiveRecord::Migration
  def up
    add_column :variants, :sku, :string
  end

  def down
    remove_column :variants, :sku, :string
  end
end
