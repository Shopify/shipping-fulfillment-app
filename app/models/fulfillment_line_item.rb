class FulfillmentLineItem < ActiveRecord::Base
  attr_protected

  belongs_to :fulfillment
  belongs_to :line_item
end