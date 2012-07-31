class VariantStockUpdateJob
  @queue = :default

  def self.perform
    Shop.all.each do |shop|
      shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
      response = shipwire.fetch_shop_inventory(shop)
      response[:stock_levels].keys.each do |sku|
        variant = Variant.find_by_sku(sku)
        variant.update_attributes(response[:stock_levels][sku])
        shopify_variant = ShopifyAPI::Variant.find(variant.shopify_variant_id)
        shopify_variant.update_attribute(quantity: variant.quantity)
      end
    end
  end
end