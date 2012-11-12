class FulfillmentLineItem < ActiveRecord::Base
  belongs_to :fulfillment
  belongs_to :line_item
end