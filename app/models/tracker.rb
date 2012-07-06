class Tracker < ActiveRecord::Base
  attr_accessible :tracking_carrier, :tracking_link, :tracking_number, :ship_date, :expected_delivery_date, :return_date, :return_condition, :shipper_name, :total, :returned, :shipped

  belongs_to :fulfillment

  #after_create :update_tracking


  private

end
