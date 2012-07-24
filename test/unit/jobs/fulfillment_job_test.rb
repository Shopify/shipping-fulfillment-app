require 'test_helper'

class FulfillmentJobTest < ActiveSupport::TestCase

  def setup
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)

    Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
  end

  test "fulfillment job makes the shipwire api call" do
    Fulfillment.any_instance.stubs(:update_fulfillment_status_on_shopify)
    ActiveMerchant::Fulfillment::ShipwireService.stubs(:new).returns(stub(:fulfill => stub(:success? => true)))
    order = create(:order)
    fulfillment = build(:fulfillment)
    fulfillment.line_items = [order.line_items.first]
    fulfillment.save

    FulfillmentJob.perform(fulfillment.id)
  end


  test "shipwire example api call" do

    FakeWeb.allow_net_connect = true

    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})

    options = {
      :warehouse => 'LAX',
      :shipping_method => 'UPS Ground',
      :email => 'cody@example.com'
    }

    us_address = {
      :name     => 'Steve Jobs',
      :company  => 'Apple Computer Inc.',
      :address1 => '1 Infinite Loop',
      :city     => 'Cupertino',
      :state    => 'CA',
      :country  => 'US',
      :zip      => '95014',
      :email    => 'steve@apple.com'
    }

    line_items = [ { :sku => 'AF0001', :quantity => 25 } ]

    response = shipwire.fulfill('123456', us_address, line_items, options)

    assert response.success?
  end

end