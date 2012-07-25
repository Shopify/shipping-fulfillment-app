FactoryGirl.define do
  factory :variant do
    sequence(:id){ |i| i }
    sequence(:shopify_variant_id){ |i| i }
    sku { SecureRandom.hex(16) }
  end
end