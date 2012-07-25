class VariantStockUpdateJob
  @queue = :default

  #do we want all variants to update or to do it by store
  # def self.perform
  #   Variant.find_each {|variant| variant.fetch_stock_levels}
  # end

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