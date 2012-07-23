require 'test_helper'

class ShippingAddressTest < ActiveSupport::TestCase
  should belong_to :order

  test "Valid shipping_address saves" do
    assert create(:shipping_address), "Valid shipping address did not save."
  end
end
