require 'test_helper'

class ShopTest < ActiveSupport::TestCase

  should have_many(:orders)
  should have_many(:variants)
  should have_many(:fulfillments)
  should validate_presence_of(:login)
  should validate_presence_of(:password)
  should validate_presence_of(:token)
  should validate_presence_of(:domain)

  def stub_shop_callbacks
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)
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
    ShopifyAPI::Webhook.expects(:create).with({topic: 'orders/paid', address: 'http://shipwireapp:3001/orderpaid', format: 'json'})
    ShopifyAPI::Webhook.expects(:create).with({topic: 'orders/cancelled', address: 'http://shipwireapp:3001/ordercancelled', format: 'json'})
    ShopifyAPI::Webhook.expects(:create).with({topic: 'orders/created', address: 'http://shipwireapp:3001/ordercreate', format: 'json'})
    ShopifyAPI::Webhook.expects(:create).with({topic: 'orders/updated', address: 'http://shipwireapp:3001/orderupdated', format: 'json'})
    ShopifyAPI::Webhook.expects(:create).with({topic: 'orders/fulfilled', address: 'http://shipwireapp:3001/orderfulfilled', format: 'json'})

    shop = create(:shop)
  end

end