class VariantSynchronizer
  @que = :variant_synchronizer_que

  def self.perform
    Variant.find_each {|variant| variant.fetch_stock_levels}
  end
end