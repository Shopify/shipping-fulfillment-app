class VariantStockUpdateJob
  @queue = :default

  #do we want all variants to update or to do it by store
  def self.perform
    Variant.find_each {|variant| variant.fetch_stock_levels}
  end
end