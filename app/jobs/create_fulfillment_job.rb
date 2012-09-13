class CreateFulfillmentJob
  @queue = :default

  def self.perform(shopify_line_items, shipping_method)
    options = {}
    options[:line_item_ids] = shopify_line_items.map do |item|
      shopify_item_id = item[:id]
      LineItem.find_by_line_item_id(id).id
    end
    options[:shipping_method] = @params[:shipping_method]

    Fulfillment.fulfill(@shop, options)
  end
end