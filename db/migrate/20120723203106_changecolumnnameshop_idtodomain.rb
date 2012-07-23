class ChangecolumnnameshopIdtodomain < ActiveRecord::Migration
  def up
    remove_column :shops, :shop_id
    add_column :shops, :domain, :string
  end
end
