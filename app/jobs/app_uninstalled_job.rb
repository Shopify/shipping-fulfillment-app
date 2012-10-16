class AppUninstalledJob
  @queue = :default

  def self.perform(shop_domain)
    Shop.find_by_domain(shop_domain).destroy
  end
end