class Variant < ActiveRecord::Base
  # TODO: delegate method calls to the shopify variant in some cases
  attr_protected

  belongs_to :shop

  validates_presence_of :activated, :sku
  validates_numericality_of :inventory, :greater_than_or_equal_to => 0
  validates :variant_id, :presence => true, :uniqueness => true

  validate :good_sku?


  def fetch_stock_levels
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})
    response = shipwire.fetch_stock_levels(:sku => sku)

    self.inventory = response.stock_levels[sku]
    self.save

    shopify_variant = ShopifyAPI::Variant.find(variant_id)
    shopify_variant.inventory_quantity = inventory
    shopify_variant.save
  end


  private

#use conditional validations

  def good_sku?
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})
    shipwire.fetch_stock_levels(:sku => sku).stock_levels[sku].present? ## clean up this line
  end

end
