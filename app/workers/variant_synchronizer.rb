class VariantSynchronizer
  @que = :variant_synchronizer_que

  def self.perform
    @shipwire_variants = Variant.all
    @shipwire_variants.each {|variant| variant.fetch_stock_levels}
  end
end