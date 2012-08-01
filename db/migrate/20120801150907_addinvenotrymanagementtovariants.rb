class Addinvenotrymanagementtovariants < ActiveRecord::Migration
  def change
    add_column :variants, :inventory_management, :string, :default => 'shipwire'
  end
end