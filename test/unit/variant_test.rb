require 'test_helper'

# FakeWeb.allow_net_connect = true

class VariantTest < ActiveSupport::TestCase


  should belong_to(:shop)
  should validate_presence_of(:shopify_variant_id)
  should validate_presence_of(:sku)

  def setup
    super
  end

  test "Valid variant saves" do
    stub_variant_callbacks
    assert create(:variant)
  end

  test "good_sku? checks sku" do
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.expects(:fetch_stock_levels).with({sku: 'AAA-999'}).returns(stub({stock_levels: {sku: nil}}))
    Variant.good_sku?(@shop, 'AAA-999')
  end

  test "fetch_quantity" do
    Resque.expects(:enqueue).returns(nil)
    variant = create(:variant)
  end
end
