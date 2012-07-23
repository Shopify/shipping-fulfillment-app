require 'test_helper'

class FulfillmentLineItemTest < ActiveSupport::TestCase
  should belong_to :fulfillment
  should belong_to :line_item

  test "Valid fulfillment line item saves" do
    assert create(:fulfillment_line_item)
  end
end
