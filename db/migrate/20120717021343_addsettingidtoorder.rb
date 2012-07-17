class Addsettingidtoorder < ActiveRecord::Migration
  def up
    add_column :orders, :setting_id, :integer
  end

  def down
    remove_column :orders, :setting_id
  end
end