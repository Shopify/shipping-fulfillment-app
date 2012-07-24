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

  test "Fulfillable" do
    fulfilled_item = create(:fulfilled_item)
    manual_service_item = create(:manual_service_item)

    assert !fulfilled_item.fulfillable?
    assert !manual_service_item.fulfillable?
  end
end
