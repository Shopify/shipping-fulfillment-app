require 'test_helper'

class VariantStockUpdateJobTest < ActiveSupport::TestCase

  test "Perform calls fetch_stock_levels on each variant" do
    Variant.any_instance.expects(:fetch_stock_levels).times(Variant.count)
    VariantStockUpdateJob.perform
  end

end