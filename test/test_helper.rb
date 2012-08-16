 ENV["RAILS_ENV"] = "test"
 require File.expand_path('../../config/environment', __FILE__)
 require 'rails/test_help'
 require 'capybara/rails'
 require 'mocha'


FakeWeb.allow_net_connect = false

class ActiveSupport::TestCase

  include FactoryGirl::Syntax::Methods

  fixtures :all

  def setup
    stub_shop_callbacks
    @shop = create(:shop)
  end

  def teardown
    FakeWeb.clean_registry
  end

  def load_json(filename)
    JSON.parse read_fixture(filename)
  end

  def read_fixture(filename)
    File.read(Rails.root.join('test/fixtures', filename))
  end

  def fake(endpoint, options={})
    body = options.has_key?(:body) ? options.delete(:body) : nil
    format = options.delete(:format) || :json
    method = options.delete(:method) || :get
    extension = ".#{options.delete(:extension) || 'json'}" unless options[:extension] == false

    base_url = options.has_key?(:base_url) ? options[:base_url] : "https://localhost.myshopify.com/"
    url = base_url + "#{endpoint}#{extension}"
    FakeWeb.register_uri(method, url, {:body => body, :status => 200, :content_type => "text/#{format}", :content_length => 1}.merge(options))
  end

  def stub_shop_callbacks
    stub_callbacks(Shop, %w(setup_webhooks set_domain create_carrier_service create_fulfillment_service check_shipwire_credentials))
  end

  def stub_variant_callbacks
    stub_callbacks(Variant, %w(confirm_sku update_shopify))
  end

  def stub_fulfillment_callbacks
    stub_callbacks(Fulfillment, %w(create_mirror_fulfillment_on_shopify update_fulfillment_status_on_shopify))
  end

  def stub_api_session
    ShopifyAPI::Base.stubs(:activate_session => true)
    ShopifyAPI::Session.new("http://localhost:3000/admin","123")
  end

  def stub_controller_filters(controller)
    controller.any_instance.stubs(:shop_exists)
    controller.any_instance.stubs(:valid_shipwire_credentials)
    controller.any_instance.stubs(:current_shop).returns(@shop)
  end

  def stub_callbacks(klass, callbacks)
    callbacks.each { |callback| klass.any_instance.stubs(callback.to_sym) }
  end

  def create_fulfillment
    order = create_order
    create(:fulfillment, :line_items => order.line_items, order: order, shop: @shop)
  end

  def create_order
    line_items = (0...5).map { create(:line_item, shop: @shop) }
    create(:order, line_items: line_items, shop: @shop)
  end
end