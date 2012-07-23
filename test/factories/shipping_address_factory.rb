FactoryGirl.define do
  factory :shipping_address do
    sequence(:id){|i| i}
    address1 '532 Beacon Street'
    address2 '7318 Black Swan Place'
    city 'Carlsbad'
    zip '92011'
    province 'CA'
    country 'United States'
  end
end