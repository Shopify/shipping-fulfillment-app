class RemoveForeignKeyReferencesToOrdersAndVariants < ActiveRecord::Migration
  def change
    change_table :line_items do |t|
      t.remove :variant_id, :order_id
    end
  end
end
