class Variant < ActiveRecord::Base
  attr_accessible :shopify_variant_id, :sku, :quantity, :backordered, :reserved, :shipping, :shipped, :availableDate, :shippedLastDay, :shippedLastWeek, :shippedLast4Weeks, :orderedLastDay, :orderedLastWeek, :orderedLast4Weeks, :title

  belongs_to :shop

  validates_presence_of :sku
  validates :shopify_variant_id, :presence => true, :uniqueness => true
  validate :confirm_sku


  after_create :update_shopify

  private

  def confirm_sku
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
    response = shipwire.fetch_stock_levels(:sku => sku)
    puts "RESPONSE: #{response.inspect}"
    if response.success && response.stock_levels[sku].present?
      self.quantity = response.stock_levels[sku]
    else
      errors.add(:variant, "Must have valid sku that is recognized by Shipwire.")
    end
  end

  def update_shopify
    shopify_variant = ShopifyAPI::Variant.find(shopify_variant_id)
    shopify_variant.update_attributes({quantity: quantity, inventory_management: 'shipwire'})
  end
end