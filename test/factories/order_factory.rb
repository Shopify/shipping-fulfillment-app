FactoryGirl.define do
  factory :order do
    sequence(:id){|i| i}
    shopify_order_id 10
    email "something@gmail.com"
    number 1345
    total_weight 43
    currency 'CAD'
    financial_status 'paid'
    name '1345'
    total_price '45.69'
    address1 '532 Beacon Street'
    address2 '7318 Black Swan Place'
    city 'Carlsbad'
    zip '92011'
    province 'CA'
    country 'United States'
    latitude  43.999
    longitude 43.999
  end
end