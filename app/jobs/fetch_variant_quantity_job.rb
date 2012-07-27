class FetchVariantQuantityJob
  @queue = :default

  def self.perform(variant)
    begin
      shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(variant.shop.credentials)
      quantity = shipwire.fetch_stock_levels(:sku => variant.sku).stock_levels[variant.sku]
      variant.update_attribute(:quantity, quantity)
      variant.update_shopify_variant
    rescue Error
      variant.destroy
    end
  end
end