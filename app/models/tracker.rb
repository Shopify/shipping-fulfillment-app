class Tracker < ActiveRecord::Base
  attr_accessible :shipwire_order_id, :tracking_carrier, :tracking_link, :tracking_number, :ship_date, :expected_delivery_date, :return_date, :return_condition, :shipper_name, :total, :returned, :shipped

  belongs_to :fulfillment

  validates_presence_of :shipwire_order_id

  after_create :update_tracking


  private

  def update_tracking
    return true
    ## fill in later
  end
end
