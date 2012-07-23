FactoryGirl.define do
  factory :fulfillment do
    sequence(:id){|i| i}
    shipping_method '1D'
    warehouse "CHI"
    shopify_fulfillment_id 12345
    address 'some serialized address'
    association :order
    email "david.thomas@shopify.com"
    status "pending"
    association :shop
  end
end