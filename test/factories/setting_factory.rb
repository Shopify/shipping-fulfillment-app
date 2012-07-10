FactoryGirl.define do
  factory :setting do 
    sequence(:id){|i| i}
    login 'David'
    password 'password'
    automatic_fulfillment false
    shop_id 'shop1.localhost'
    token '1391230123912301230132'
  end
end