require 'test_helper'

class TrackerTest < ActiveSupport::TestCase
  should belong_to :fulfillment

  def setup
    Setting.any_instance.stubs(:setup_webhooks)
    Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
    @fulfillment = create(:fulfillment, :line_items => [build(:line_item)])
  end

  test "valid tracker saves " do
    tracker = Tracker.new(:fulfillment => @fulfillment)

    assert tracker.save, "Valid tracker did not save."
    assert tracker.reload.shipwire_order_id.present?
  end

  test "Presence of shipwire order id is validated" do
    tracker = Tracker.new(:fulfillment => @fulfillment)
    tracker.expects(:create_shipwire_order_id)

    assert !tracker.save
  end
end
