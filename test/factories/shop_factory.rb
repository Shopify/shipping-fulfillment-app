FactoryGirl.define do
  factory :shop do
    sequence(:id){|i| i}
    login 'David'
    password 'password'
    automatic_fulfillment false
    sequence(:domain){|i| "domain"+i.to_s }
    token '1391230123912301230132'

    factory :shop_true do
      automatic_fulfillment true
      domain 'anothershop'
    end

  end
end