FactoryGirl.define do
  factory :fulfillment_line_item do
    fulfillment_id 1
    association :line_item
  end
end