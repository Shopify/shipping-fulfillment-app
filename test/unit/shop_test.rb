require 'test_helper'

class ShopTest < ActiveSupport::TestCase

  should have_many(:fulfillments)

  def setup
  end

  test "Valid shop saves" do
    stub_shop_callbacks

    assert create(:shop)
  end

  test "Credentials returns shops credentials" do
    stub_shop_callbacks
    shop = create(:shop)

    assert_equal shop.credentials, {login: shop.login, password: shop.password, test: false}
  end

  test "Webhooks created after save" do
    stub_callbacks(Shop, %w(check_shipwire_credentials create_carrier_service set_domain create_fulfillment_service))

    ShopifyAPI::Session.expects(:temp).times(3).yields
    expect_webhook('app', 'uninstalled')
    expect_webhook('fulfillments', 'create')
    expect_webhook('fulfillments', 'update')
    shop = create(:shop)
  end

  test "check_shipwire_credentials validates credentials" do
    stub_callbacks(Shop, %w(create_carrier_service set_domain create_fulfillment_service setup_webhooks))
    response = stub(:success? => true)

    ShipwireApp::Application.config.shipwire_fulfillment_service_class.any_instance.expects(:fetch_stock_levels).returns(response)
    shop = create(:shop)
  end

  test "automatic fulfillment setting for a shop" do
    stub_shop_callbacks
    shop = create(:shop)
    assert !shop.automatic_fulfillment?

    shop.automatic_fulfillment = true
    assert shop.automatic_fulfillment?
  end

  test "create fulfillment service webhook makes shopify api call with correct params" do
    ShopifyAPI::Session.expects(:temp).yields
    ShopifyAPI::FulfillmentService.expects(:create).with(fulfillment_service_params)
    stub_callbacks(Shop, %w(check_shipwire_credentials create_carrier_service set_domain setup_webhooks))
    create(:shop)
  end

  private

  def expect_webhook(object,topic)
    ShopifyAPI::Webhook.expects(:create).with({topic: "#{object}/#{topic}", address: "http://davefp.showoff.io/#{object}#{topic}", format: 'json'})
  end

  def fulfillment_service_params
    {
      fulfillment_service:{
        credential1: nil,
        credential2: nil,
        name: 'Shipwire App',
        handle: 'shipwire_app',
        email: nil,
        endpoint: nil,
        template: nil,
        remote_address: 'http://davefp.showoff.io',
        include_pending_stock: 0,
        response_format: 'json'
      }
    }
  end

end