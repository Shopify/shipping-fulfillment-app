class LineItem < ActiveRecord::Base

  attr_protected :order

  belongs_to :order

  validates_presence_of :product_id, :variant_id, :line_item_id, :quantity

  def fulfillable?
    return true if (fulfillment_service == "shipwire") && (fulfillment_status != "fulfilled")
  end

end