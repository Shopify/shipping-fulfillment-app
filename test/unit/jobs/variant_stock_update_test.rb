require 'test_helper'

class VariantStockUpdateJobTest < ActiveSupport::TestCase

  def setup
    super
    stub_variant_callbacks
    stub_shopify_update

    @variant1 = create(:variant, shop: @shop)
    @variant2 = create(:variant, shop: @shop)

    @response = {}
    @response[:stock_levels] = {}
    @response[:stock_levels][@variant1.sku] = {quantity: "10"}
    @response[:stock_levels][@variant2.sku] = {shippedLastWeek: "200"}
  end

  def stub_shopify_update
    ShopifyAPI::Variant.stubs(:find)
    NilClass.any_instance.stubs(:update_attribute)
  end

  test "Perform calls fetch_shop_inventory and updates variants" do

    ActiveMerchant::Fulfillment::ShipwireService.any_instance.stubs(:fetch_shop_inventory).with(@shop).returns(@response)

    VariantStockUpdateJob.perform
    assert_equal "10", @variant1.reload.quantity
    assert_equal "200", @variant2.reload.shippedLastWeek
  end

  test "Perform updates the inventory for multiple shops" do
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.stubs(:fetch_shop_inventory).with(@shop).returns(@response)

    shop2 = create(:shop)
    variant3 = create(:variant, shop: shop2)
    response2 = {}
    response2[:stock_levels] = {}
    response2[:stock_levels][variant3.sku] = {orderedLastWeek: "250"}
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.stubs(:fetch_shop_inventory).with(shop2).returns(response2)

    shop3 = create(:shop)
    variant4 = create(:variant, shop: shop3)
    response3 = {}
    response3[:stock_levels] = {}
    response3[:stock_levels][variant4.sku] = {backordered: "5"}
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.stubs(:fetch_shop_inventory).with(shop3).returns(response3)

    VariantStockUpdateJob.perform

    assert_equal "10", @variant1.reload.quantity
    assert_equal "200", @variant2.reload.shippedLastWeek
    assert_equal "250", variant3.reload.orderedLastWeek
    assert_equal "5", variant4.reload.backordered
  end
end