class Variant < ActiveRecord::Base
  attr_accessible :shopify_variant_id, :sku, :quantity, :backordered, :reserved, :shipping, :shipped, :availableDate, :shippedLastDay, :shippedLastWeek, :shippedLast4Weeks, :orderedLastDay, :orderedLastWeek, :orderedLast4Weeks, :title

  belongs_to :shop

  validates_presence_of :sku
  validates :shopify_variant_id, :presence => true, :uniqueness => true
  validate :confirm_sku

  after_create :update_shopify



  def last_fulfilled_order_address
    item = shop.line_items.order("created_at DESC")
      .where('variant_id = ? AND fulfillment_status = ?', shopify_variant_id, 'fulfilled')
      .first

    item.order.address if item.present?
  end

  def self.batch_create_variants(shop, shopify_variant_ids)
   failures = shopify_variant_ids.select do |shopify_variant_id|
      shopify_variant = ShopifyAPI::Variant.find(shopify_variant_id)
      variant = Variant.new(shopify_variant_id: shopify_variant_id, sku: shopify_variant.sku, title: shopify_variant.title)
      !variant.save
    end
    failures.length
  end

  def self.update_skus(management, params)
    ids,skus,failures = [],[],[]
    case management
      when 'shipwire'
        params.each do |id, sku|
          variant = Variant.find(id.to_i)
          if variant.update_attribute(:sku, sku)
            ids << id
            skus << sku
          else
            failures << id
          end
        end
      when 'shopify' || 'none'
        params.each do |id, sku|
          variant = ShopifyAPI::Variant.find(id.to_i)
          variant.sku = sku
          if variant.save!
            ids << id
            skus << sku
          else
            failures << id
          end
        end
      else
    end
    [ids, skus, failures]
  end

  private

  def confirm_sku
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
    response = shipwire.fetch_stock_levels(:sku => sku)
    if response.success && response.stock_levels[sku].present?
      self.quantity = response.stock_levels[sku]
    else
      errors.add(:variant, "Must have valid sku that is recognized by Shipwire.")
    end
  end

  def update_shopify
    shopify_variant = ShopifyAPI::Variant.find(shopify_variant_id)
    shopify_variant.save({quantity: quantity, inventory_management: 'shipwire'}) #TODO find out how to do this
  end
end