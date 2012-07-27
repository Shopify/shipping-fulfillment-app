FactoryGirl.define do
  factory :fulfillment do
    sequence(:id){|i| i}
    association :shop
    association :order

    shipping_method '1D'
    warehouse "CHI"
    shopify_fulfillment_id 12345
    email "david.thomas@shopify.com"
    status "pending"
    tracking_carrier "USPS"
    tracking_link "https://app.shipwire.com/c/t/xxx1:yyy3"
    tracking_number 9400110200793596422990
    ship_date DateTime.parse("2011-04-08 09:33:10")
    expected_delivery_date DateTime.parse("2011-04-15 00:00:00")
    return_date DateTime.parse("2011-05-04 17:33:25")
    return_condition "GOOD"
    shipper_name "USPS First-Class Mail Parcel + Delivery Confirmation"
    total "4.47"
    returned "NO"
    shipped "YES"
  end
end