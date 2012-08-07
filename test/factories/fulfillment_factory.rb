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


origin_lat: #&lt;BigDecimal:7fb04b019098,'0.35694E1',18(45)&gt;, origin_long: #&lt;BigDecimal:7fb04b018e90,'0.867E2',18(45)&gt;, destination_lat: #&lt;BigDecimal:7fb04b018c38,'0.9432E1',18(45)&gt;, destination_long: #&lt;BigDecimal:7fb04b018a30,'0.51342E2',18(45)
origin_lat: #&lt;BigDecimal:7fb04b00b3f8,'0.35694E1',18(45)&gt;, origin_long: #&lt;BigDecimal:7fb04b00b1f0,'0.867E2',18(45)&gt;, destination_lat: #&lt;BigDecimal:7fb04b00afe8,'0.9432E1',18(45)&gt;, destination_long: #&lt;BigDecimal:7fb04b00ade0,'0.51342E2',18(45)