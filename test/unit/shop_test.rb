require 'test_helper'

class ShopTest < ActiveSupport::TestCase
  test "valid shop saves" do
    shop = Shop.new(login: "user@email.com", password:"5555", token:"token", automatic_fulfillment: false, domain: "other-shop.myshopify.com")
    shop.stubs(:setup_webhooks)

    assert shop.save
  end

  test "build makes valid shop" do
    fake "admin/shop", :method => :get, :body => load_fixture('shop'), :format => 'json'
    shop = Shop.build({login: "user@email.com", password:"5555", token:"token", automatic_fulfillment: false})

    assert shop.valid?
  end


  test "valid webhook api call after save" do
    fake "admin/shop", :method => :get, :body => load_fixture('shop'), :format => 'json'
    fake "admin/webhooks", :method => :post, :format => 'json'
    shop = Shop.build({login: "user@email.com", password:"5555", token:"token", automatic_fulfillment: false})

    assert shop.save
    assert_equal FakeWeb.last_request.body, '{"webhook":{"topic":"orders/paid","shop":1,"address":"http://shipwireapp:3001/orderpaid","format":"json"}}'
  end

  should validate_presence_of(:login)
  should validate_presence_of(:password)
  should validate_presence_of(:token)
  should validate_presence_of(:domain)
  should have_many(:orders)
  should have_many(:variants)
  should have_many(:fulfillments)
end
