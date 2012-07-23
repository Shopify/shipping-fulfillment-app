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
    association(:shipping_address)

    ignore do
        line_item_count 5
    end

    after(:create) do |order, evaluator|
        FactoryGirl.create_list(:line_item, evaluator.line_item_count, order: order)
    end
  end
end