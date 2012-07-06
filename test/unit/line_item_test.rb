require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  should validate_presence_of :fulfillment_id
  should validate_presence_of :product_id
  should validate_presence_of :variant_id
  should validate_presence_of :line_item_id

  should belong_to :fulfillment

  test "valid line_item saves" do
    item = FactoryGirl.build(:line_item)
    assert item.save, "Valid item did not save."
  end
end
