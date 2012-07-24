class Removecolumnaddressfromfulfillments < ActiveRecord::Migration
  def change
    remove_column :fulfillments, :address
  end
end
