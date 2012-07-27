require 'test_helper'

class ShopifyVariantUpdateJobTest < ActiveSupport::TestCase
  def setup
    stub_variant_callbacks
    @variant = create(:variant)
  end

  test "Perform makes api call and updates shopify variant" do
    ShopifyAPI::Variant.expects(:find).returns(@variant)
    ShopifyVariantUpdateJob.perform(1, "10")

    assert_equal @variant.reload.quantity, "10"
  end
end