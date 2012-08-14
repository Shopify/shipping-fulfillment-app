class Changequantitytointeger < ActiveRecord::Migration
  def change
    remove_column :variants, :quantity
    add_column :variants, :quantity, :integer
  end
end
