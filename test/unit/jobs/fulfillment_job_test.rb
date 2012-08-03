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

  ## WONT WORK WITH OVERIDDEN fulfill in shipwire_extensions.rb
  # test "shipwire example api call" do

  #   FakeWeb.allow_net_connect = true

  #   shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})

  #   options = {
  #     :warehouse => 'LAX',
  #     :shipping_method => 'UPS Ground',
  #     :email => 'cody@example.com'
  #   }

  #   us_address = {
  #     :name     => 'Steve Jobs',
  #     :company  => 'Apple Computer Inc.',
  #     :address1 => '1 Infinite Loop',
  #     :city     => 'Cupertino',
  #     :state    => 'CA',
  #     :country  => 'US',
  #     :zip      => '95014',
  #     :email    => 'steve@apple.com'
  #   }

  #   line_items = [ { :sku => 'AF0001', :quantity => 25 } ]

  #   response = shipwire.fulfill('123456', us_address, line_items, options)

  #   assert response.success?
  # end

end