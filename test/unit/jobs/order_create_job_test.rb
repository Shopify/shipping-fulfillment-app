require 'test_helper'

class OrderCreateJobTest < ActiveSupport::TestCase

  def setup
    super
  end

  test "Perform creates new order" do
    params = load_json('order_create.json')['order'].with_indifferent_access

    assert_difference "@shop.orders.count", 1 do
      OrderCreateJob.perform(params,@shop)
    end
  end
end