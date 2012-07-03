class Setting < ActiveRecord::Base
  attr_protected

  has_many :variants
  has_many :fulfillments

  validates_presence_of :login, :password, :token
  validates :shop_id, :presence => true, :uniqueness => true

  after_create :setup_webhooks

  def self.build(base_attributes)
    setting = Setting.new(base_attributes)
    setting.shop_id = ShopifyAPI::Shop.current.myshopify_domain
    return setting
  end

  private

  def setup_webhooks
    shop = ShopifyAPI::Shop.current
    hooks = []
    hooks << ShopifyAPI::Webhook.new({topic: 'orders/paid', shop: shop.id, address: 'http://shipwireapp:3001/orderpaid', format: 'json'})
    #hooks << ShopifyAPI::Webhook.new({topic: 'orders/cancelled', shop: shop.id, address: 'http://shipwireapp:3001/orderpaid', format: 'json'})
    hooks.each do |hook|
      if !hook.save
        raise(RuntimeError, hook.errors.inspect)
      end
    end
  end

end
