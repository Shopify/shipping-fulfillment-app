class ShopifyVariantUpdateJob
  @queue = :default

  def self.perform(shopify_variant_id, quantity)
    shopify_variant = ShopifyAPI::Variant.find(shopify_variant_id)
    shopify_variant.update_attribute('quantity',quantity)
  end
end