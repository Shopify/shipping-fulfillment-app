class ShippingAddress < ActiveRecord::Base
  attr_protected

  belongs_to :order

end