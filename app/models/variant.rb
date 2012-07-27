class Variant < ActiveRecord::Base
  # TODO: delegate method calls to the shopify variant in some cases
  attr_accessible :quantity, :backordered, :reserved, :shipping, :shipped, :availableDate, :shippedLastDay, :shippedLastWeek, :shippedLast4Weeks, :orderedLastDay, :orderedLastWeek, :orderedLast4Weeks

  belongs_to :shop

  after_create :fetch_quantity

  validates_presence_of :sku
  validates :shopify_variant_id, :presence => true, :uniqueness => true


  def self.good_sku?

  end
  
  private

  def update_shopify_variant
    Resque.enqueue(ShopifyVariantUpdateJob, shopify_order_id, quantity)
  end

  def fetch_quantity
    Resque.enqueue(FetchVariantQuantityJob, variant)
    #will destroy variant if bad sku
  end
end
