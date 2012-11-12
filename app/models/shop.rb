class Shop < ActiveRecord::Base
  Rails.env == 'development'||'test' ? HOOK_ADDRESS = 'http://davefp.showoff.io/' : HOOK_ADDRESS = 'production root url'

  attr_accessible :login, :password, :automatic_fulfillment, :valid_credentials
  
  has_many :fulfillments, :dependent => :destroy
  has_many :line_items, :dependent => :destroy

  validates_presence_of :login, :password, :token
  validates :domain, :presence => true, :uniqueness => true
  validate :check_shipwire_credentials
  after_create :setup_webhooks, :create_carrier_service, :create_fulfillment_service

  def credentials
    # test = Rails.env != 'production'
    {login: login, password: password, test: false}
  end

  def base_url
    domain
  end

  def shopify_session(&blk)
    ShopifyAPI::Session.temp(base_url, token, &blk)
  end

  private

  def setup_webhooks

    hooks = {
      'fulfillments/create' => 'fulfillmentscreate',
      'fulfillments/update' => 'fulfillmentsupdate',
      'app/uninstalled' => 'appuninstalled'
    }
    hooks.each { |topic, action| make_webhook(topic, action) }
  end

  def check_shipwire_credentials
    return if password.empty?
    shipwire = ShipwireApp::Application.config.shipwire_fulfillment_service_class.new(credentials.merge({:test => true}))
    response = shipwire.fetch_stock_levels()
    update_attribute(:valid_credentials, response.success?)
    unless response.success?
      errors.add(:password, "Must have valid shipwire credentials to use the services provided by this app.")
    end
  end

  def make_webhook(topic, action)
    shopify_session {
      ShopifyAPI::Webhook.create({topic: topic, address: HOOK_ADDRESS + action, format: 'json'})
    }
  end

  def create_carrier_service
    params = {

    }
    shopify_session {
      carrier_service = ShopifyAPI::CarrierService.create(params)
    }
  end

  def create_fulfillment_service

    params = {
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

    shopify_session {
      ShopifyAPI::FulfillmentService.create(params)
    }
  end
end
