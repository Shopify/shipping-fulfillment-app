class ShippingAddress < ActiveRecord::Base
  attr_protected :order

  belongs_to :order

end