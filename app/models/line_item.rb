class LineItem < ActiveRecord::Base
  attr_protected

  belongs_to :fulfillment

  validates_presence_of(:fulfillment_id, :product_id, :variant_id, :line_item_id)
  
end
