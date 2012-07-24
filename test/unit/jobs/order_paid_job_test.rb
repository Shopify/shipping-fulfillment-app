require 'test_helper'

class OrderPaidJobTest < ActiveSupport::TestCase
  def setup
    Shop.any_instance.stubs(:setup_webhooks)
    @order = create(:order)
  end

  test "Perform calls Fulfillment.fulfill with appropriate parameters" do
    Fulfillment.expects(:fulfill).with(@order.shop, {order_id: @order.id, shipping_method: 'Ground'})
    params = [{"code"=>'Ground', "price"=>"10.00", "source"=>"shopify", "title"=>"Generic Shipping"}]
    OrderPaidJob.perform(@order, params)
  end
end