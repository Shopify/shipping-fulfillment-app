class Variant < ActiveRecord::Base
  # TODO: delegate method calls to the shopify variant in some cases
  attr_protected
  #attr_accessible :quantity, :backordered, :reserved, :shipping, :shipped, :availableDate, :shippedLastDay, :shippedLastWeek, :shippedLast4Weeks, :orderedLastDay, :orderedLastWeek, :orderedLast4Weeks

  belongs_to :shop

  after_create :fetch_quantity

  validates_presence_of :sku
  validates :shopify_variant_id, :presence => true, :uniqueness => true


  private

#TODO: decide sku checking

  def good_sku?
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
    shipwire.fetch_stock_levels(:sku => sku).stock_levels[sku].present? ## clean up this line
  end

  def update_shopify_variant
    Resque.enqueue(ShopifyVariantUpdateJob, shopify_order_id, quantity)
  end

  def fetch_quantity
    Resque.enqueue(FetchVariantQuantityJob, variant)
  end
end
