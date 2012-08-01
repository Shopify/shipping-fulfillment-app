
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl_rails'
require 'mocha'

Shop.any_instance.stubs(:setup_webhooks)
Shop.any_instance.stubs(:set_domain)
Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
Variant.any_instance.stubs(:update_shopify)
Variant.any_instance.stubs(:confirm_sku)



shop = FactoryGirl.create(:shop, domain: 'shop1.localhost')
order = FactoryGirl.create(:order, shop:shop)
fulfillment = FactoryGirl.create(:fulfillment, shop: shop, line_items: [order.line_items.first])
variant = FactoryGirl.create(:variant, shopify_variant_id: 4, shop: shop)