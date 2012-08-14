require 'test_helper'

class ExternalControllerTest < ActionController::TestCase
  def setup
    super
    ExternalController.any_instance.stubs(:verify_shopify_request)
  end

  test "shipping_rates" do
  end

  test "fetch_stock" do

  end

  test "fetch_tracking_numbers" do

  end

  test "fulfill_order" do

  end

  test "build_xml" do
    assert_equal build_xml({"sku1" => 1, "sku2" => 2})
  end

  def example_xml
    '<StockLevels><Product><Sku>sku1</Sku><Quantity>1</Quantity></Product><Product><Sku>sku2</Sku><Quantity>2</Quantity></Product></StockLevels>'
  end
end
