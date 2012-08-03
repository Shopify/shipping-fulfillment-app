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
end
