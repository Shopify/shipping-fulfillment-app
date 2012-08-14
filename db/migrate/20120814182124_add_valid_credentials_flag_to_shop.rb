class AddValidCredentialsFlagToShop < ActiveRecord::Migration
  def change
    add_column :shops, :valid_credentials, :boolean, :default => false
  end
end
