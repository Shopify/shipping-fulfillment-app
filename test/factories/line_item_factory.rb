FactoryGirl.define do
  factory :line_item do
    sequence(:id){|i| i}
    association :shop
    fulfillment_service "shipwire"
    fulfillment_status nil
    grams 0
    sequence(:line_item_id){|j| j}
    price "8.00"
    product_id 93464918
    quantity 1
    requires_shipping true
    sku "779i4k"
    title "API NIKE BASKETBALL"
    # variant_id 218594758
    variant_title "used ball"
    vendor "Nike"
    name "API NIKE BASKETBALL"
    factory :fulfilled_item do
        fulfillment_status "fulfilled"
    end
    factory :manual_service_item do
        fulfillment_service "manual"
    end
  end
end