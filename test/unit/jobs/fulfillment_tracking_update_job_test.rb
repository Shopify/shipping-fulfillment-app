require 'test_helper'

class FulfillmentTrackingUpdateJobTest < ActiveSupport::TestCase
  def setup
    super
    Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
  end

  test "Perform makes tracking requests and updates fulfillment" do
    fulfillment = create(:fulfillment, expected_delivery_date: DateTime.now + 1.week, shop: @shop, line_items: [create(:line_item)])
    active_order_ids = [fulfillment.shipwire_order_id]
    response = {fulfillment.shipwire_order_id => {returned: "YES"}}
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.expects(:fetch_shop_tracking_info).with(active_order_ids).returns(response)

    FulfillmentTrackingUpdateJob.perform
    assert_equal "YES", fulfillment.reload.returned
  end

  test "Perform only updates recent fulfillments" do
    fulfillment1 = create(:fulfillment, expected_delivery_date: DateTime.now + 1.week, shop: @shop, line_items: [create(:line_item)])
    fulfillment2 = create(:fulfillment, expected_delivery_date: DateTime.now - 2.months, shop: @shop, line_items: [create(:line_item)])

    active_order_ids = [fulfillment1.shipwire_order_id]
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.expects(:fetch_shop_tracking_info).with(active_order_ids).returns({})

    FulfillmentTrackingUpdateJob.perform
  end
end