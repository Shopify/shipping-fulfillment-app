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
    origin_lat BigDecimal.new("3.5694")
    origin_long BigDecimal.new("86.7")
    destination_lat BigDecimal.new("9.432")
    destination_long BigDecimal.new("51.3 4")

    factory :other_fulfillment do
        origin_lat BigDecimal.new("56.8")
        origin_long BigDecimal.new("53.4")
        destination_lat BigDecimal.new("34.2")
        destination_long BigDecimal.new("102.4")
    end
  end
end