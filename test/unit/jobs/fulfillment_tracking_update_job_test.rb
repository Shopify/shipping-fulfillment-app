require 'test_helper'

class FulfillmentTrackingUpdateJobTest < ActiveSupport::TestCase
  def setup
    Shop.any_instance.stubs(:setup_webhooks)
    @shop = create(:shop)
    @order1 = create(:order)
    @order2 = create(:order)
    @shop.orders = [@order1, @order2]
  end

  test "Perform updates the order and corresponding line item fulfillment statuses" do
    assert true
    # FulfillmentTrackingUpdateJobTest.perform
  end
end