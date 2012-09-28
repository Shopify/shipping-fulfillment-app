class AppUninstalledJob
  @queue = :default

  def self.perform(shop_domain)
    Shop.where(:domain => shop_domain).destroy_all
  end
end