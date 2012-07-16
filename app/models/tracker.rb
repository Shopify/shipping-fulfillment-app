class Tracker < ActiveRecord::Base
  attr_accessible :tracking_carrier, :tracking_link, :tracking_number, :ship_date, :expected_delivery_date, :return_date, :return_condition, :shipper_name, :total, :returned, :shipped, :fulfillment

  belongs_to :fulfillment

  validates_presence_of :shipwire_order_id

  before_validation :create_shipwire_order_id

  def create_shipwire_order_id
    number = SecureRandom.hex(16)
    self.shipwire_order_id = "#{fulfillment.shopify_order_id}.#{number}"
  end
end
