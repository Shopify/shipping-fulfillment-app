
if Rails.env.production?
  ShipwireApp::Application.config.shipwire_fulfillment_service_class = ActiveMerchant::Fulfillment::ShipwireService
  ShipwireApp::Application.config.shipwire_carrier_service_class = ActiveMerchant::Shipping::Shipwire
else
  ShipwireApp::Application.config.shipwire_fulfillment_service_class = ActiveMerchant::Fulfillment::ShipwireBetaService
  ShipwireApp::Application.config.shipwire_carrier_service_class = ActiveMerchant::Shipping::ShipwireBeta
end