class FetchVariantQuantityJob
  @queue = :default

  def self.perform(variant)
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(variant.shop.credentials)
    quantity = shipwire.fetch_stock_levels(:sku => variant.sku).stock_levels[variant.sku]
    variant.update_attribute('quantity', quantity)
  end
end