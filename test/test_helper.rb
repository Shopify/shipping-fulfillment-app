 ENV["RAILS_ENV"] = "test"
 require File.expand_path('../../config/environment', __FILE__)
 require 'rails/test_help'
 require 'capybara/rails'
 require 'mocha'


FakeWeb.allow_net_connect = false

class ActiveSupport::TestCase

  fixtures :all


  def setup
    ActiveResource::Base.format = :json
    ShopifyAPI.constants.each do |const|
      begin
        const = "ShopifyAPI::#{const}".constantize
        const.format = :json if const.respond_to?(:format=)
      rescue NameError
      end
    end

    ShopifyAPI::Base.site = "http://localhost:3000/admin"
    ShopifyAPI::Base.password = nil
    ShopifyAPI::Base.user = nil
  end

  def teardown
    FakeWeb.clean_registry    
  end

  def load_fixture(name, format=:json)
    File.read(File.dirname(__FILE__) + "/fixtures/#{name}.#{format}")
  end

  def fake(endpoint, options={})
    body = options.has_key?(:body) ? options.delete(:body) : nil
    format = options.delete(:format) || :json
    method = options.delete(:method) || :get
    extension = ".#{options.delete(:extension) || 'json'}" unless options[:extension] == false

    url = "http://localhost:3000/#{endpoint}#{extension}"
    FakeWeb.register_uri(method, url, {:body => body, :status => 200, :content_type => "text/#{format}", :content_length => 1}.merge(options))
  end

end


class ActionDispatch::IntegrationTest
  include Capybara::DSL


  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end