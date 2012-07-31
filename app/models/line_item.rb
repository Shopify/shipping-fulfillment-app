class LineItem < ActiveRecord::Base

  attr_protected :order

  belongs_to :order

  validates_presence_of :product_id, :variant_id, :line_item_id, :quantity

  def fulfillable?
    (fulfillment_service == "shipwire") && (fulfillment_status != "fulfilled")
  end

  def fulfillable_by_shipwire?
    requires_shipping? && fulfillment_service == 'shipwire'
  end

end