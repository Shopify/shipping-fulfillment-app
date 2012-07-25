class Addshipwirefieldstovariants < ActiveRecord::Migration
  def up
    remove_column :variants, :inventory
    add_column :variants, :quantity, :string
    add_column :variants, :backordered, :string
    add_column :variants, :reserved, :string
    add_column :variants, :shipping, :string
    add_column :variants, :shipped, :string
    add_column :variants, :availableDate, :string
    add_column :variants, :shippedLastDay, :string
    add_column :variants, :shippedLastWeek, :string
    add_column :variants, :shippedLast4Weeks, :string
    add_column :variants, :orderedLastDay, :string
    add_column :variants, :orderedLastWeek, :string
    add_column :variants, :orderedLast4Weeks, :string
  end
end
