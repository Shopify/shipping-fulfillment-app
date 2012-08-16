require 'test_helper'

# FakeWeb.allow_net_connect = true

class VariantTest < ActiveSupport::TestCase

  def setup
    super
  end

  test "#last_fulfilled_order_address gets the address of last fulfilled ordered with given variant" do
    stub_variant_callbacks

    order = create_order
    item = order.line_items.first
    item.update_attribute(:fulfillment_status, 'fulfilled')
    variant = create(:variant, shopify_variant_id: item.variant_id, shop: item.shop)

    expected_address = order.address
    assert_equal expected_address, variant.last_fulfilled_order_address
  end

  test "Valid variant saves" do
    stub_variant_callbacks
    assert create(:variant)
  end

  test "confirm_sku checks sku" do
    Variant.any_instance.stubs(:update_shopify)
    variant = build(:variant, shop: @shop)
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.expects(:fetch_stock_levels).with({sku: variant.sku}).returns(stub({stock_levels: {variant.sku => 10}, success: true}))

    assert variant.save
    assert_equal 10, variant.quantity
  end

  test "update_shopify makes update_attributes call to shopify" do
    Variant.any_instance.stubs(:confirm_sku)
    variant = build(:variant)
    ShopifyAPI::Variant.expects(:find).with(variant.shopify_variant_id).returns(nil)
    NilClass.any_instance.expects(:update_attributes).with({quantity: variant.quantity, inventory_management: 'shipwire'})
    assert variant.save
  end

  test "#self.batch_create_variants successfully creates variants" do
    basketball = stub(sku: '1', title: 'basketball')
    baseball = stub(sku: '2', title: 'baseball')
    football = stub(sku: '3', title: 'football')

    ShopifyAPI::Variant.expects(:find).with(1).returns(basketball)
    ShopifyAPI::Variant.expects(:find).with(2).returns(baseball)
    ShopifyAPI::Variant.expects(:find).with(3).returns(football)

    stub_variant_callbacks
    assert_difference "Variant.count", 3 do
      Variant.batch_create_variants(@shop, [1,2,3])
    end
  end

  test "#self.batch_create_variants counts number of failed creation attempts" do
    basketball = stub(sku: '1', title: 'basketball')
    baseball = stub(sku: '2', title: 'baseball')
    football = stub(sku: '3', title: 'football')

    unsaved = stub(save: false)
    saved = stub(save: true)

    ShopifyAPI::Variant.expects(:find).with(1).returns(basketball)
    ShopifyAPI::Variant.expects(:find).with(2).returns(baseball)
    ShopifyAPI::Variant.expects(:find).with(3).returns(football)

    Variant.stubs(:new).with(shopify_variant_id: 1, sku: '1', title: 'basketball').returns(unsaved)
    Variant.stubs(:new).with(shopify_variant_id: 2, sku: '2', title: 'baseball').returns(unsaved)
    Variant.stubs(:new).with(shopify_variant_id: 3, sku: '3', title: 'football').returns(saved)

    stub_variant_callbacks
    assert_equal 2, Variant.batch_create_variants(@shop, [1,2,3])
  end
end