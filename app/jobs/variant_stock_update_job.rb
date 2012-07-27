class VariantStockUpdateJob
  @queue = :default

  def self.perform
    Shop.all.each do |shop|
      shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
      response = shipwire.fetch_shop_inventory(shop)
      response[:stock_levels].keys.each do |key|
        variant = Variant.where("sku = ?", key).first
        variant.update_attributes(response[:stock_levels][key])
      end
    end
  end
end