class Shop < ActiveRecord::Base
  Rails.env == 'development'||'test' ? HOOK_ADDRESS = 'http://shipwireapp:3001/' : HOOK_ADDRESS = 'production root url'

  attr_accessible :login, :password, :automatic_fulfillment

  has_many :variants
  has_many :fulfillments
  has_many :orders
  has_many :line_items

  validates_presence_of :login, :password, :token
  #validates :domain, :presence => true, :uniqueness => true
  validate :check_shipwire_credentials

  before_create :set_domain
  after_create :setup_webhooks, :create_carrier_service, :create_fulfillment_service

  def credentials
    Rails.env == 'production' ? test = false : test = true
    {login: login, password: password, test: test}
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

  def set_domain
    domain = ShopifyAPI::Shop.current.myshopify_domain
  end

  def setup_webhooks
    return if Rails.env == 'development'

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
    return if Rails.env == 'development'
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(credentials)
    response = shipwire.fetch_stock_levels()
    if response.success?
      self.update_attribute(:valid_credentials, true)
    else
      errors.add(:shop, "Must have valid shipwire credentials to use the services provided by this app.")
    end
  end

  def make_webhook(topic, action)
    ShopifyAPI::Webhook.create({topic: topic, address: HOOK_ADDRESS + action, format: 'json'})
  end

  def create_carrier_service
    return if Rails.env == 'development'
    carrier_service = ShopifyAPI::CarrierService.create()
  end

  def create_fulfillment_service
    return if Rails.env == 'development'

    params = {
      fulfillment_service:{
        fulfillment_service_type: 'app',
        credential1: login,
        credential2: password,
        name: 'shipwire_app',
        handle: 'shipwire_app',
        email: nil,
        endpoint: nil,
        template: nil,
        remote_address: nil,
        include_pending_stock: 0
      }
    }

    ShopifyAPI::FulfillmentService.create(params)
  end
end
