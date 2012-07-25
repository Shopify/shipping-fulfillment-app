class Addcolumntrackingtotrackers < ActiveRecord::Migration
  def up
    add_column :trackers, :active, :boolean, :default => true
  end
end
