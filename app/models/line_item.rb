class LineItem < ActiveRecord::Base

  attr_accessible :fulfillment_service, :fulfillment_status, :grams, :price, :product_id, :shop_id,
                  :quantity, :requires_shipping, :sku, :title, :vendor, :name, :line_item_id, :variant_title

  belongs_to :shop

  validates_presence_of :shop, :product_id, :line_item_id, :quantity

  #variant_id is the variant_id of the shopify line_item

  def self.new_from_params(shop, params)
    LineItem.new(params.except("variant_inventory_management", "properties", "id", "variant_id")
                       .merge({"shop_id" => shop.id, "line_item_id" => params["id"]}))
  end

  def fulfillable?
    (fulfillment_service == "shipwire") && (fulfillment_status != "fulfilled")
  end

  def fulfillable_by_shipwire?
    requires_shipping? && fulfillment_service == 'shipwire'
  end

  def total
    price.to_f * quantity
  end

  def shopify_product_link
    "https://#{shop.domain}/admin/products/#{product_id}"
  end

end