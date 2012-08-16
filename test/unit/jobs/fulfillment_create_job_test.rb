require 'test_helper'

class FulfillmentCreateJobTest < ActiveSupport::TestCase

  def setup
    super
  end

  test "Perform calls Fulfillment.fulfill with the appropriate params" do
    items = []
    5.times { items << create(:line_items) }
    shopify_line_item_ids = items.map(&:line_item_id)
    FulfillmentCreateJob.perform(shopify_line_item_ids, '1D')
    expected{
      
    }

    Fulfillment.expects(:fulfill).with(@shop, )
  end
end