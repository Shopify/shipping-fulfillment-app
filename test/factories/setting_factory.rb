FactoryGirl.define do
  factory :setting do
    sequence(:id){|i| i}
    login 'David'
    password 'password'
    automatic_fulfillment false
    shop_id 'davidshop'
    token '1391230123912301230132'

    factory :setting_true do
      automatic_fulfillment true
      shop_id 'anothershop'
    end

  end
end