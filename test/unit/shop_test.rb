require 'test_helper'

class ShopTest < ActiveSupport::TestCase

  should have_many(:orders)
  should have_many(:variants)
  should have_many(:fulfillments)
  should validate_presence_of(:login)
  should validate_presence_of(:password)
  should validate_presence_of(:token)
  should validate_presence_of(:domain)

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
    Shop.any_instance.stubs(:set_domain)
    ['paid','cancelled','create','updated','fulfilled'].each{ |name| expect_webhook(name) }
    shop = create(:shop)
  end

  test "automatic fulfillment setting for a shop" do
    stub_shop_callbacks
    shop = create(:shop)
    assert !shop.automatic_fulfillment?

    shop.automatic_fulfillment = true
    assert shop.automatic_fulfillment?
  end

end