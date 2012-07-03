class Variant < ActiveRecord::Base
  attr_protected

  belongs_to :setting

  validates_presence_of :setting_id, :activated, :sku
  validates_numericality_of :inventory, :greater_than_or_equal_to => 0
  validates :variant_id, :presence => true, :uniqueness => true
  validate :good_sku?

  before_save :fetch_stock_levels

  def fetch_stock_levels
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})
    response = shipwire.fetch_stock_levels(:sku => variant.sku)

    #update inventory based on response

    puts "Response #{response.inspect}"
    puts response[:stock_levels][variant.sku]
  end 

  def self.manage_inventory_with_shipwire(variant_id, shop_id)
    if !Variant.where('variant_id = ?', variant_id).first.nil?
      variant = Variant.where('variant_id = ?', variant_id).first
    else
      variant = Variant.new({variant_id: variant_id})
    end
    variant.setting_id = Setting.where('shop_id = ?', shop_id).first.id
    variant.activated = true
    ## send notice to shopify
    return true if variant.save
    return false
  end

  def self.manage_inventory_with_shopify(variant_id, shop_id)
    variant = Variant.find_by_id(variant_id)
    variant.activated = false
    ## send notice to shopify
    return true if variant.save
    return false
  end

  ##duplicate code here
  # def self.check_sku?(sku)
  #   shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})
  #   !(shipwire.fetch_stock_levels(:sku => sku)[sku].nil?)
  # end

  #private

  def good_sku?
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})
    !(shipwire.fetch_stock_levels(:sku => sku)[sku].nil?)
  end

end
