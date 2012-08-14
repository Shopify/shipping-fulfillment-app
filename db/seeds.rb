
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl_rails'
require 'mocha'

Shop.any_instance.stubs(:setup_webhooks)
Shop.any_instance.stubs(:set_domain)
Shop.any_instance.stubs(:create_fulfillment_service)
Shop.any_instance.stubs(:check_shipwire_credentials)
Shop.any_instance.stubs(:create_carrier_service)
Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
Fulfillment.any_instance.stubs(:update_fulfillment_status_on_shopify)
Variant.any_instance.stubs(:update_shopify)
Variant.any_instance.stubs(:confirm_sku)
ShopifyAPI::Base.stubs(:activate_session => true)
ShopifyAPI::Session.new("http://localhost:3000/admin","123")


shop = FactoryGirl.create(:shop, domain: 'shop1.localhost')
order = FactoryGirl.create(:order, shop:shop)
FactoryGirl.create(:order, shop:shop)
FactoryGirl.create(:order, shop:shop)
another_order = FactoryGirl.create(:order, shop:shop, financial_status: 'pending')
fulfillment = FactoryGirl.create(:fulfillment, shop: shop, line_items: [order.line_items.first])
FactoryGirl.create(:other_fulfillment, shop: shop, line_items: another_order.line_items[0..3])
FactoryGirl.create(:variant, shop: shop)