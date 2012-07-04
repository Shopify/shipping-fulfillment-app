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
    #update self.inventory based on response

    puts "Response #{response.inspect}"
    puts response[:stock_levels][variant.sku]
  end 


  private

  def good_sku?
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})
    !(shipwire.fetch_stock_levels(:sku => sku)[sku].nil?)
  end

end
