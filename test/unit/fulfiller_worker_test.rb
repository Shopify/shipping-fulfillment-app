require 'test_helper'

class FulfillerWorkerTest < ActiveSupport::TestCase
  test "perform should send valid " do
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.expects(:fulfill).with(
      '18.adflafalalfkaf', 
      {address: 'some shipping address'},
      [{sku: '134141', quantity: 10}],
      {warehouse: 'CHI', email: 'example@shopify.com', shipping_method: '1D'}
    ).returns(stub({success?: true}))

    Fulfillment.any_instance.expects(:success)
    
    fulfillment = FactoryGirl.create(:fulfillment)
    Fulfiller.perform(
      fulfillment.id,
      '18.adflafalalfkaf',
      {address: 'some shipping address'},
      [{sku: '134141', quantity: 10}],
      {warehouse: 'CHI', email: 'example@shopify.com', shipping_method: '1D'}
    )
  end
end