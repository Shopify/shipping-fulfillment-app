FactoryGirl.define do
  factory :fulfillment do
    sequence(:id){|i| i}
    shipping_method '1D'
    warehouse "CHI"
    shopify_fulfillment_id 12345
    address 'some serialized address'
    shopify_order_id 19232494
    email "david.thomas@shopify.com"
    status "pending"
    setting_id 121
    line_items []
  end
end