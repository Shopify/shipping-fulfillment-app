class UpdateFulfillmentJob
  @queue = :default

  def self.perform(params, shop_domain)
    shop = Shop.find_by_domain(domain)
    fulfillment = Fulfillment.find_by_shopify_fulfillment_id(params[:id])

    fulfillment.update_attributes(Fulfillment.extract_params(params))
  end
end