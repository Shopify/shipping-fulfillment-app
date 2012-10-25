require 'test_helper'

class ShippingExtensionTest < ActiveSupport::TestCase

  def setup
    @shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(credentials)
  end

  test "order request contains affiliated credential" do
    output = @shipwire.build_fulfillment_request(order_id, address, items, options)

    assert_equal order_request_expected_xml, output
  end

  test "parse fulfillment response correctly parses response" do
    response = @shipwire.parse_fulfillment_response(order_response_xml)
    keys = [:origin_lat, :origin_long, :destination_lat, :destination_long]

    assert response[:success]
    keys.each do |key|
      assert_nil response[key]
    end
  end

  test "build total inventory request renders correctly" do
    output = @shipwire.build_total_inventory_request

    assert_equal total_inventory_request_expected_xml, output
  end

  test "parse tracking update response parses expected input correctly" do
    response = @shipwire.parse_tracking_update_response(tracking_update_response_xml)

    expected = {
      "40299" => {
        shipped: "Yes",
        shipper_name: "USPS First-Class Mail Parcel + Delivery Confirmation",
        return_condition: "GOOD",
        total: "4.47",
        returned: "Yes",
        ship_date: DateTime.parse("22 Mar 2011 00:00:00 +0000"),
        expected_delivery_date: DateTime.parse("22 Mar 2011 00:00:00 +0000"),
        return_date: DateTime.parse("04 May 2011 17:33:25 +0000"),
        tracking_carrier: "USPS",
        tracking_link: "http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?origTrackNum=9400110200793472606087",
        tracking_number: "9400110200793472606087"
      }
    }
    id = "40299"

    expected[id].each do |key, value|
      assert_equal value, response[id][key]
    end
  end

  test "parse total inventory response parses expected input correclty" do
    response = @shipwire.parse_total_inventory_response(total_inventory_response_expected_xml)
    expected = {
      "GD802-024" => {
        quantity: "14",
        pending: "300",
        backordered: "0",
        reserved: "15",
        shipping: "7",
        shipped: "7013",
        availableDate: "2012-01-19",
        shippedLastDay: "13",
        shippedLastWeek: "84",
        shippedLast4Weeks: "401",
        orderedLastDay: "15",
        orderedLastWeek: "99",
        orderedLast4Weeks: "416"
        },
      "GD201-500"=>{
        quantity: "32",
        pending: "500",
        backordered: "0",
        reserved: "17",
        shipping: "0",
        shipped: "1997",
        availableDate: "2012-02-21",
        shippedLastDay: "11",
        shippedLastWeek: "74",
        shippedLast4Weeks: "221",
        orderedLastDay: "19",
        orderedLastWeek: "90",
        orderedLast4Weeks: "242"
      }
    }

    assert response[:success]

    expected["GD201-500"].each do |key, value|
      assert_equal value, response[:stock_levels]["GD201-500"][key]
    end

    expected["GD802-024"].each do |key, value|
      assert_equal value, response[:stock_levels]["GD802-024"][key]
    end
  end


  ##############
  ##### Helpers
  ##############
  def options
    options = {
      shipping_method: '1D',
      warehouse: nil
    }
  end

  def order_id
    '12.k3132k341j341'
  end

  def credentials
    {login: 'api_user@example.com', password: 'yourpassword'}
  end

  def items
    items = [{
        quantity: 1,
        sku: "k9e34u"
    }]
  end

  def address
    address = {
      name: "Davids Address",
      address1: "7318 Black Swan Place",
      address2: nil,
      company: nil,
      city: "Carlsbad",
      state: "California",
      country: "United States",
      zip: "92011"
    }
  end

  def shipwire
    ActiveMerchant::Fulfillment::ShipwireService.new(credentials)
  end

  def total_inventory_response_expected_xml
'<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE InventoryUpdateResponse SYSTEM "http://www.shipwire.com/exec/download/InventoryUpdateResponse.dtd">
<InventoryUpdateResponse>
    <Status>0</Status>
    <Product code="GD802-024"
             quantity="14"
             good="14"
             pending="300"
             backordered="0"
             reserved="15"
             shipping="7"
             shipped="7013"
             consuming="0"
             consumed="0"
             creating="0"
             created="0"
             availableDate="2012-01-19"
             shippedLastDay="13"
             shippedLastWeek="84"
             shippedLast4Weeks="401"
             orderedLastDay="15"
             orderedLastWeek="99"
             orderedLast4Weeks="416" />
    <Product code="GD201-500"
             quantity="32"
             good="32"
             pending="500"
             backordered="0"
             reserved="17"
             shipping="0"
             shipped="1997"
             consuming="0"
             consumed="0"
             creating="0"
             created="0"
             availableDate="2012-02-21"
             shippedLastDay="11"
             shippedLastWeek="74"
             shippedLast4Weeks="221"
             orderedLastDay="19"
             orderedLastWeek="90"
             orderedLast4Weeks="242" />
    <TotalProducts>2</TotalProducts>
</InventoryUpdateResponse>'
  end

  def tracking_update_response_xml
'TrackingUpdateResponse SYSTEM "http://www.shipwire.com/exec/download/TrackingUpdateResponse.dtd">
<TrackingUpdateResponse>
    <Status>0</Status>
    <Order id="40299"
           shipped="Yes"
           shipper="USPS FC"
           shipperFullName="USPS First-Class Mail Parcel + Delivery Confirmation"
           shipDate="2011-03-15 10:40:06"
           expectedDeliveryDate="2011-03-22 00:00:00"
           handling="0.00"
           shipping="4.47"
           packaging="0.00"
           total="4.47"
           returned="Yes"
           returnDate="2011-05-04 17:33:25"
           returnCondition="GOOD"
           href="https://app.shipwire.com/c/t/xxx1:yyy2"
           affiliateStatus="shipwireFulfilled"
           manuallyEdited="No">
        <TrackingNumber carrier="USPS"
                        href="http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?origTrackNum=9400110200793472606087">
        9400110200793472606087</TrackingNumber>
    </Order>
</TrackingUpdateResponse>'
  end


  def total_inventory_request_expected_xml
'<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE InventoryStatus SYSTEM "http://www.shipwire.com/exec/download/InventoryUpdate.dtd">
<InventoryUpdate>
  <EmailAddress>api_user@example.com</EmailAddress>
  <Password>yourpassword</Password>
  <Server>Production</Server>
</InventoryUpdate>
'
  end


  def order_request_expected_xml
'<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE OrderList SYSTEM "http://www.shipwire.com/exec/download/OrderList.dtd">
<OrderList>
  <AffiliateId>1894</AffiliateId>
  <EmailAddress>api_user@example.com</EmailAddress>
  <Password>yourpassword</Password>
  <Server>Production</Server>
  <Referer>Active Fulfillment</Referer>
  <Order id="12.k3132k341j341">
    <Warehouse>00</Warehouse>
    <AddressInfo type="Ship">
      <Name>
        <Full>Davids Address</Full>
      </Name>
      <Address1>7318 Black Swan Place</Address1>
      <Address2></Address2>
      <City>Carlsbad</City>
      <State>California</State>
      <Country>United States</Country>
      <Zip>92011</Zip>
    </AddressInfo>
    <Shipping>1D</Shipping>
    <Item num="0">
      <Code>k9e34u</Code>
      <Quantity>1</Quantity>
    </Item>
  </Order>
</OrderList>
'
  end


  def geo_order_response_xml
'<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE
SubmitOrderResponse SYSTEM "http://www.shipwire.com/exec/download/SubmitOrderResponse.dtd">
<SubmitOrderResponse>
  <Status>0</Status>
  <TotalOrders>1</TotalOrders>
  <TotalItems>1</TotalItems>
  <TransactionId>1319266806-257193-1</TransactionId>
  <OrderInformation>
    <Order number="SG1011004883" id="1319266806-257193-1"
    status="accepted">
      <Shipping>
        <Warehouse>UK</Warehouse>
        <Service>Royal Mail Airmail</Service>
        <Cost>5.23</Cost>
      </Shipping>
      <Routing>
        <Origin>
          <Latitude>50.9118</Latitude>
          <Longitude>0.12776</Longitude>
        </Origin>
        <Destination>
          <Latitude>34.075</Latitude>
          <Longitude>-117.378</Longitude>
        </Destination>
      </Routing>
    </Order>
  </OrderInformation>
  <ProcessingTime units="ms">917</ProcessingTime>
</SubmitOrderResponse>'
  end

  def order_response_xml
'<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE
SubmitOrderResponse SYSTEM "http://www.shipwire.com/exec/download/SubmitOrderResponse.dtd">
<SubmitOrderResponse>
  <Status>0</Status>
  <TotalOrders>1</TotalOrders>
  <TotalItems>1</TotalItems>
  <TransactionId>1319266806-257193-1</TransactionId>
  <OrderInformation>
    <Order number="SG1011004883" id="1319266806-257193-1"
    status="accepted">
      <Shipping>
        <Warehouse>UK</Warehouse>
        <Service>Royal Mail Airmail</Service>
        <Cost>5.23</Cost>
      </Shipping>
    </Order>
  </OrderInformation>
  <ProcessingTime units="ms">917</ProcessingTime>
</SubmitOrderResponse>'
  end
end