require 'test_helper'

class FulfillmentTest < ActiveSupport::TestCase

  def setup
    stub_shop_callbacks
    @shop = shops(:david)
  end

  test "Valid fulfillment saves" do
    fulfillment = build(:fulfillment, :line_items => [build(:line_item, shop: @shop)])

    assert fulfillment.save
    assert fulfillment.shipwire_order_id.present?
  end

  test "Updating fulfillment does not change shipwire_order_id" do
    fulfillment = create_fulfillment

    before = fulfillment.shipwire_order_id
    fulfillment.update_attribute(:expected_delivery_date, DateTime.now)
    after = fulfillment.reload.shipwire_order_id

    assert_equal before, after
  end

  test "Fulfillment with invalid shipping_method does not save" do
    fulfillment = build(:fulfillment, :shipping_method => 'Space')

    assert !fulfillment.save, "Fulfillment with invalid shipping_method saves."
  end

  test "Geolocation? returns true if all geolocation fields are present and false otherwise" do
    fulfillment = create_fulfillment
    assert fulfillment.geolocation?

    fulfillment.update_attribute('destination_lat',nil)
    assert !fulfillment.geolocation?
  end

  test "Updating the fulfillment status makes a ShopifyAPI::Fulfillment call" do
    Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
    fulfillment = create_fulfillment

    shopify_fulfillment = mock_shopify_fulfillment
    ShopifyAPI::Session.expects(:temp).yields
    ShopifyAPI::Fulfillment.expects(:find).returns(shopify_fulfillment)
    shopify_fulfillment.expects(:complete)
    fulfillment.success
  end

  test "State machine transitions call update_fulfillment_status_with_shopify" do
    Fulfillment.any_instance.expects(:update_fulfillment_status_on_shopify).times(3)

    fulfillment = create_fulfillment
    fulfillment.success

    fulfillment.update_attribute(:status, 'pending')
    fulfillment.cancel

    fulfillment.update_attribute(:status, 'pending')
    fulfillment.record_failure
  end

  private

  def mock_shopify_fulfillment
    mock("Fulfillment") do
      stubs(:complete)
      stubs(:cancel)
    end
  end


end