require 'test_helper'

# FakeWeb.allow_net_connect = true

class VariantTest < ActiveSupport::TestCase


  should belong_to(:shop)
  should validate_presence_of(:shopify_variant_id)
  should validate_presence_of(:sku)

  def setup
    Variant.any_instance.stubs(:fetch_quantity)
  end

  test "valid variant saves" do
    assert create(:variant)
  end
end
