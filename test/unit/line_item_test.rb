require 'test_helper'

class LineItemTest < ActiveSupport::TestCase

  def setup
    super
  end

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
