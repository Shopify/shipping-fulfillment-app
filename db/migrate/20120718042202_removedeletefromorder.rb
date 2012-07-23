class Removedeletefromorder < ActiveRecord::Migration
  def up
    remove_column :orders, :deleted_at
  end

  def down
    add_column :orders, :deleted_at, :datetime
  end
end
