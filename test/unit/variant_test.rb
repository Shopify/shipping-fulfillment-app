require 'test_helper'

# FakeWeb.allow_net_connect = true

class VariantTest < ActiveSupport::TestCase


  def setup
    super
  end

  should belong_to(:shop)

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
end