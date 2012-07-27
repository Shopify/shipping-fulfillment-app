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
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)
  end

  def stub_variant_callbacks
    Variant.any_instance.stubs(:fetch_quantity)
    Variant.any_instance.stubs(:update_shopify_variant)
  end

  def stub_fulfillment_callbacks
    Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
  end
end

## No integration tests yet
# class ActionDispatch::IntegrationTest
#   include Capybara::DSL


#   def teardown
#     Capybara.reset_sessions!
#     Capybara.use_default_driver
#   end
# end