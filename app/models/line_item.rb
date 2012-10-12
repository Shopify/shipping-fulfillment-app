class LineItem < ActiveRecord::Base

  attr_protected :order

  belongs_to :order
  belongs_to :shop

  validates_presence_of :shop, :product_id, :variant_id, :line_item_id, :quantity

  #variant_id is the variant_id of the shopify line_item

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