FactoryGirl.define do
  factory :fulfillment do
    shipping_method '1D'
    address 'some serialized address'
    shopify_order_id 19232494
    email "david.thomas@shopify.com"
    status "pending"
    setting_id 121
  end
end