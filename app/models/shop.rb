class Shop < ActiveRecord::Base
  HOOK_ADDRESS = 'http://shipwireapp:3001/'

  attr_protected

  has_many :variants
  has_many :fulfillments
  has_many :orders

  validates_presence_of :login, :password, :token
  validates :domain, :presence => true, :uniqueness => true

  after_create :setup_webhooks

  def self.build(base_attributes)
    shop = Shop.new(base_attributes) # just call super
    shop.domain = ShopifyAPI::Shop.current.myshopify_domain # TODO: before create
  end

  def self.exists? # TODO: can this be improved /refactored?
    Shop.where('domain = ?', ShopifyAPI::Shop.current.myshopify_domain).any?
  end

  def automatically_fulfill?
    automatic_fulfillment
  end

  private

  ## hook address will need to change for production
  def setup_webhooks
    shop = ShopifyAPI::Shop.current # might be able to get this without api call
    hooks = {
      'orders/paid' => 'orderpaid',
      'orders/cancelled' => 'ordercancelled',
      'orders/created' => 'ordercreate',
      'orders/updated' => 'orderupdated',
      'orders/fulfilled' => 'orderfulfilled'
    }
    hooks.each { |topic, action| make_webhook(shop, topic, action) }
  end

  def make_webhook(shop, topic, action)
    ShopifyAPI::Webhook.create({topic: topic, shop: shop.id, address: HOOK_ADDRESS + action, format: 'json'})
  end

end
