class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :login 
      t.string :password
      t.boolean :automatic_fulfillment
      t.string :shop_id
      t.string :token
      t.timestamps
    end
  end
end
