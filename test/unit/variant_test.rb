require 'test_helper'

# FakeWeb.allow_net_connect = true

class VariantTest < ActiveSupport::TestCase

#   should validate_uniqueness_of(:variant_id)

#   should validate_presence_of(:setting_id)
#   should validate_presence_of(:activated)
#   should validate_presence_of(:sku)

#   should validate_numericality_of(:inventory)

#   should belong_to(:shop)

#   def setup
#     Variant.any_instance.stubs(:good_sku?).returns(true)
#     Variant.any_instance.stubs(:fetch_stock_levels).returns(true)
#   end

#   test "valid variant saves" do
#     good = Variant.new(setting_id: 2, variant_id: 11, inventory: 15, activated:true, sku:"4E2-9552")
#     assert good.save
#   end

#   test "inventory must be non-negative number" do
#     synced_variant = Variant.new(setting_id: 3, variant_id: 12, inventory: -1, activated:true, sku:"4E2-9552")
#     assert !synced_variant.save
#   end

#   #how to test good_sku?????? Mock all the things!
end
