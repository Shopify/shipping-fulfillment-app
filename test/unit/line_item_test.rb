require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  should validate_presence_of :product_id
  should validate_presence_of :variant_id
  should validate_presence_of :line_item_id
  should validate_presence_of :quantity

  should belong_to :order

  test "valid line_item saves" do
    assert create(:line_item), "Valid item did not save."
  end

  test "Items that are fulfilled or have other fulfillment service are not fulfillable" do
    fulfilled = create(:fulfilled_item)
    manual = create(:manual_service_item)

    assert !fulfilled.fulfillable?
    assert !manual.fulfillable?
  end
end
