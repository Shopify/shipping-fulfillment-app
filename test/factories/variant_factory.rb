FactoryGirl.define do
  factory :variant do
    sequence(:id){ |i| i }
    sequence(:shopify_variant_id){ |i| i }
    sku { SecureRandom.hex(16) }
    title "Rawling Baseball"
    quantity 100
    backordered "10"
    reserved "5"
    shipping "3"
    shipped "547"
    availableDate "2011-04-08 09:33:10 UTC"
    shippedLastDay "3"
    shippedLastWeek "9"
    shippedLast4Weeks "43"
    orderedLastDay "2"
    orderedLastWeek "9"
    orderedLast4Weeks "43"
  end
end