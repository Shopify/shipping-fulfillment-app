require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  should validate_presence_of :fulfillment_id
  should validate_presence_of :product_id
  should validate_presence_of :variant_id
  should validate_presence_of :line_item_id

  shoul belong_to :fulfillment

  test "valid line_item saves" do

end
end
