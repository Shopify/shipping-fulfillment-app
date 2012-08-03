class ShippingExtensionTest < ActiveSupport::TestCase

  test "order request contains affiliated credential" do
    assert true
  end

  def credentials
    {login: 'api_user@example.com', password: 'yourpassword'}
  end

  def shipwire
    ActiveMerchant::Fulfillment::ShipwireService.new(credentials)
  end

  def order_response_expected_xml
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

  def order_request_expected_xml
    '<?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE InventoryUpdate SYSTEM "http://www.shipwire.com/exec/download/InventoryUpdate.dtd">
    <InventoryUpdate>
        <AffiliateId>1894</AffiliateId>
        <Username>api_user@example.com</Username>
        <Password>yourpassword</Password>
        <Server>Production</Server>
    </InventoryUpdate>'
  end
end