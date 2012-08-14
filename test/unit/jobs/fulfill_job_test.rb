require 'test_helper'

class FulfillmentJobTest < ActiveSupport::TestCase

  def setup
    super
    stub_fulfillment_callbacks
  end

  test "fulfillment job makes the shipwire api call" do
    response = ActiveMerchant::Fulfillment::Response.new(true,nil)
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.expects(:fulfill).returns(response)
    FulfillmentJob.perform(create_fulfillment.id)
  end

  test "fulfillment job updates the geo attributes on fulfillment" do
    params ={
      origin_lat: '88.932',
      origin_long: '93.2323',
      destination_lat: '-40.2',
      destination_long: '-32.2'
    }
    response = ActiveMerchant::Fulfillment::Response.new(true,nil, params)
    fulfillment = create_fulfillment
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.expects(:fulfill).returns(response)
    FulfillmentJob.perform(fulfillment)

    assert_equal BigDecimal.new(params[:origin_lat]), fulfillment.reload.origin_lat
    assert_equal BigDecimal.new(params[:origin_long]), fulfillment.origin_long
    assert_equal BigDecimal.new(params[:destination_lat]), fulfillment.destination_lat
    assert_equal BigDecimal.new(params[:destination_long]), fulfillment.destination_long

  end

end