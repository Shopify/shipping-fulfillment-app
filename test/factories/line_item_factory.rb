FactoryGirl.define do 
  factory :line_item do
    fulfillment_service "manual"
    fulfillment_status nil
    grams 0
    line_item_id 217209322
    price "8.00"
    product_id 93464918
    quantity 1
    requires_shipping true
    sku ""
    title "API NIKE BASKETBALL"
    variant_id 218594758
    variant_title nil
    vendor "Nike"
    name "API NIKE BASKETBALL"
    variant_inventory_management ""
    association(:fulfillment)
  end
end