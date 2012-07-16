class Setting < ActiveRecord::Base
  # TODO: rename setting?
  attr_protected

  has_many :variants
  has_many :fulfillments

  validates_presence_of :login, :password, :token
  validates :shop_id, :presence => true, :uniqueness => true

  after_create :setup_webhooks

  def self.build(base_attributes)
    setting = Setting.new(base_attributes) # just call super
    setting.shop_id = ShopifyAPI::Shop.current.myshopify_domain # TODO: before create
    return setting # TODO: don't need return, it's implicit
  end

  def self.exists? # TODO: can this be improved /refactored?
    Setting.where('shop_id = ?', ShopifyAPI::Shop.current.myshopify_domain).any?
  end

  def automatically_fulfill?
    automatic_fulfillment
  end

  private

  def setup_webhooks
    shop = ShopifyAPI::Shop.current
    hooks = []
    #need to change address for production
    hooks << ShopifyAPI::Webhook.new({topic: 'orders/paid', shop: shop.id, address: 'http://shipwireapp:3001/orderpaid', format: 'json'})
    #hooks << ShopifyAPI::Webhook.new({topic: 'orders/cancelled', shop: shop.id, address: 'http://shipwireapp:3001/orderpaid', format: 'json'})
    hooks.each do |hook|
      if !hook.save
        puts hook.errors.inspect
        #raise(RuntimeError, hook.errors.inspect)
      end
    end
  end

end
