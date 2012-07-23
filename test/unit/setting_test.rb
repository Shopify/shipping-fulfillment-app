require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  test "valid setting saves" do
    setting = Setting.new(login: "user@email.com", password:"5555", token:"token", automatic_fulfillment: false, shop_id: "other-shop.myshopify.com")
    setting.stubs(:setup_webhooks)

    assert setting.save
  end

  test "build makes valid setting" do
    fake "admin/shop", :method => :get, :body => load_fixture('shop'), :format => 'json'
    setting = Setting.build({login: "user@email.com", password:"5555", token:"token", automatic_fulfillment: false})

    assert setting.valid?
  end


  test "valid webhook api call after save" do
    fake "admin/shop", :method => :get, :body => load_fixture('shop'), :format => 'json'
    fake "admin/webhooks", :method => :post, :format => 'json'
    setting = Setting.build({login: "user@email.com", password:"5555", token:"token", automatic_fulfillment: false})

    assert setting.save
    assert_equal FakeWeb.last_request.body, '{"webhook":{"topic":"orders/paid","shop":1,"address":"http://shipwireapp:3001/orderpaid","format":"json"}}'
  end

  should validate_presence_of(:login)
  should validate_presence_of(:password)
  should validate_presence_of(:token)
  should validate_presence_of(:shop_id)
  should validate_uniqueness_of(:shop_id)
  should have_many(:orders)
  should have_many(:variants)
  should have_many(:fulfillments)
end
