class Changevariantidtoshopifyvariantid < ActiveRecord::Migration
  def change
    remove_column :variants, :variant_id
    add_column :variants, :shopify_variant_id, :integer
  end
end