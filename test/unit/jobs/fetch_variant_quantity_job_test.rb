require 'test_helper'

class FetchVariantQuantityJobTest < ActiveSupport::TestCase

  def setup
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)
    Variant.any_instance.stubs(:fetch_quantity)

    @shop = create(:shop)
    @variant = create(:variant, shop: @shop)
  end

  test "Perform updates variant quantity" do
    stock_levels = {}
    stock_levels[@variant.sku] = "10"
    quantity = stub(stock_levels: stock_levels)
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.expects(:fetch_stock_levels).returns(quantity)

    FetchVariantQuantityJob.perform(@variant)
    assert_equal @variant.reload.quantity, "10"
  end
end