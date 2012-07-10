class AddColumnShopifyFulfillmentIdToFulfillments < ActiveRecord::Migration
  def change
    add_column :fulfillments, :shopify_fulfillment_id, :integer
  end
end
