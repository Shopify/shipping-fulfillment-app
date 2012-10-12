class Shop < ActiveRecord::Base
  Rails.env == 'development'||'test' ? HOOK_ADDRESS = 'http://shipwireapp:5000/' : HOOK_ADDRESS = 'production root url'

  attr_accessible :login, :password, :automatic_fulfillment, :valid_credentials

  has_many :variants, :dependent => :destroy
  has_many :fulfillments, :dependent => :destroy
  has_many :orders, :dependent => :destroy
  has_many :line_items, :dependent => :destroy

  validates_presence_of :login, :password, :token
  validates :domain, :presence => true, :uniqueness => true
  validate :check_shipwire_credentials
  after_create :setup_webhooks, :create_carrier_service, :create_fulfillment_service

  def credentials
    test = Rails.env != 'production'
    {login: login, password: password, test: test}
  end

  def base_url
    Rails.env.production? ? domain : "#{domain}:3000"
  end

  private

  def setup_webhooks

    hooks = {
      'fulfillments/create' => 'fulfillmentcreated',
      'app/uninstalled' => 'appuninstalled'
    }
    hooks.each { |topic, action| make_webhook(topic, action) }
  end

  def check_shipwire_credentials
    return if password.empty?
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(credentials)
    response = shipwire.fetch_stock_levels()
    update_attribute(:valid_credentials, response.success?)
    unless response.success?
      errors.add(:password, "Must have valid shipwire credentials to use the services provided by this app.")
    end
  end

  def make_webhook(topic, action)
    ShopifyAPI::Session.temp(base_url, token) {
      ShopifyAPI::Webhook.create({topic: topic, address: HOOK_ADDRESS + action, format: 'json'})
    }
  end

  def create_carrier_service
    ShopifyAPI::Session.temp(base_url, token) {
      carrier_service = ShopifyAPI::CarrierService.create
    }
  end

  def create_fulfillment_service

    params = {
      fulfillment_service:{
        fulfillment_service_type: 'api',
        credential1: nil,
        credential2: nil,
        name: 'Shipwire App',
        handle: 'shipwire_app',
        email: nil,
        endpoint: nil,
        template: nil,
        remote_address: 'http://localhost:5000',
        include_pending_stock: 0
      }
    }

    ShopifyAPI::Session.temp(base_url, token) {
      ShopifyAPI::FulfillmentService.create(params)
    }
  end
end
