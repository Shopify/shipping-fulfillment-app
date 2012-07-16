class LineItem < ActiveRecord::Base
  attr_accessible :fulfillment_service, :fulfillment_status, :grams, :line_item_id, :price, :product_id, :quantity, :requires_shipping, :sku, :title, :variant_id, :variant_title, :vendor, :name, :variant_inventory_management

  belongs_to :fulfillment

  validates_presence_of :product_id, :variant_id, :line_item_id
end