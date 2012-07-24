require 'test_helper'

class TrackerTest < ActiveSupport::TestCase
  should belong_to :fulfillment
  should validate_presence_of :shipwire_order_id

  def setup
    Shop.any_instance.stubs(:setup_webhooks)
    Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
    @fulfillment = create(:fulfillment, :line_items => [build(:line_item)])
  end

  test "valid tracker saves " do
    assert create(:tracker)
  end
end
