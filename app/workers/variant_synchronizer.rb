class VariantSynchronizer
  @que = :variant_synchronizer_que

  def self.perform
    # TODO: can we fetch all stock levels at once?
    Variant.find_each {|variant| variant.fetch_stock_levels}
  end
end