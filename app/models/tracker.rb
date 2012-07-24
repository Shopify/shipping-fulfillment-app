class Tracker < ActiveRecord::Base
  attr_protected

  belongs_to :fulfillment

  validates_presence_of :shipwire_order_id

end
