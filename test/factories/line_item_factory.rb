FactoryGirl.define do
  factory :line_item do
    sequence(:id){|i| i}
    fulfillment_service "manual"
    fulfillment_status "pending"
    grams 0
    sequence(:line_item_id){|j| j}
    price "8.00"
    product_id 93464918
    quantity 1
    requires_shipping true
    sku "779i4k"
    title "API NIKE BASKETBALL"
    variant_id 218594758
    variant_title "used ball"
    vendor "Nike"
    name "API NIKE BASKETBALL"
    order
  end
end