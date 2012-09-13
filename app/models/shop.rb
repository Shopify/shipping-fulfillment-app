class Shop < ActiveRecord::Base
  Rails.env == 'development'||'test' ? HOOK_ADDRESS = 'http://shipwireapp:3001/' : HOOK_ADDRESS = 'production root url'

  attr_accessible :login, :password, :automatic_fulfillment

  has_many :variants
  has_many :fulfillments
  has_many :orders
  has_many :line_items

  validates_presence_of :login, :password, :token
  validates :domain, :presence => true, :uniqueness => true
  validate :check_shipwire_credentials
  after_create :setup_webhooks, :create_carrier_service, :create_fulfillment_service

  def credentials
    test = Rails.env != 'production'
    {login: login, password: password, test: test}
  end

  def base_url
    "#{domain}:3000"
  end

  def shop_fulfillment_type
    if automatic_fulfillment
      return 'Automatic'
    end
    'Manual'
  end

  def not_shop_fulfillment_type
    if automatic_fulfillment
      return 'Manual'
    end
    'Automatic'
  end

  private

  def setup_webhooks

    hooks = {
      'orders/paid' => 'orderpaid',
      'orders/cancelled' => 'ordercancelled',
      'orders/create' => 'ordercreate',
      'orders/updated' => 'orderupdated',
      'orders/fulfilled' => 'orderfulfilled',
      'fulfillments/create' => 'fulfillmentcreated'
    }
    hooks.each { |topic, action| make_webhook(topic, action) }
  end

  def check_shipwire_credentials
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(credentials)
    response = shipwire.fetch_stock_levels()
    if response.success?
      self.update_attribute(:valid_credentials, true)
    else
      errors.add(:shop, "Must have valid shipwire credentials to use the services provided by this app.")
    end
  end

  def make_webhook(topic, action)
    ShopifyAPI::Session.temp(base_url, token) {
      ShopifyAPI::Webhook.create({topic: topic, address: HOOK_ADDRESS + action, format: 'json'})
    }
  end

  def create_carrier_service
    ShopifyAPI::Session.temp(base_url, token) {
      carrier_service = ShopifyAPI::CarrierService.create()
    }
  end

  def create_fulfillment_service

    params = {
      fulfillment_service:{
        fulfillment_service_type: 'api',
        credential1: nil,
        credential2: nil,
        name: 'shipwire_app',
        handle: 'shipwire_app',
        email: nil,
        endpoint: nil,
        template: nil,
        remote_address: nil,
        include_pending_stock: 0
      }
    }

    ShopifyAPI::Session.temp(base_url, token) {
      ShopifyAPI::FulfillmentService.create(params)
    }
  end
end
