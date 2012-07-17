require 'test_helper'

class ShippingAddressTest < ActiveSupport::TestCase
  should belong_to :order
end
