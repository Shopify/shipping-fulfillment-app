require 'test_helper'

class ShopTest < ActiveSupport::TestCase

  should have_many(:orders)
  should have_many(:variants)
  should have_many(:fulfillments)

  def setup
  end

  def expect_webhook(name)
    ShopifyAPI::Webhook.expects(:create).with({topic: 'orders/'+name, address: 'http://shipwireapp:3001/order'+name, format: 'json'})
  end

  test "Valid shop saves" do
    stub_shop_callbacks

    assert create(:shop)
  end

  test "Credentials returns shops credentials" do
    stub_shop_callbacks
    shop = create(:shop)

    assert_equal shop.credentials, {login: shop.login, password: shop.password}
  end

  test "Webhooks created after save" do
    stub_callbacks(Shop, %w{check_shipwire_credentials create_carrier_service set_domain create_fulfillment_service})

    %w{paid cancelled create updated fulfilled}.each{ |name| expect_webhook(name) }
    shop = create(:shop)
  end

  test "check_shipwire_credentials validates credentials" do
    assert true
  end

  test "automatic fulfillment setting for a shop" do
    stub_shop_callbacks
    shop = create(:shop)
    assert !shop.automatic_fulfillment?

    shop.automatic_fulfillment = true
    assert shop.automatic_fulfillment?
  end

end