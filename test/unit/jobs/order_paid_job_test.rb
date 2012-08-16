require 'test_helper'

class OrderPaidJobTest < ActiveSupport::TestCase
  def setup
    super
    @order = create_order
  end

  test "Perform calls Fulfillment.fulfill with appropriate parameters" do
    Fulfillment.expects(:fulfill).with(@shop, {order_ids: [@order.id], shipping_method: 'Ground'})
    params = [{"code"=>'Ground', "price"=>"10.00", "source"=>"shopify", "title"=>"Generic Shipping"}]
    OrderPaidJob.perform(@order.id, @shop.id, params)
  end
end