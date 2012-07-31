module ApplicationHelper

  def service_is_not_shipwire?(order)
    order.line_items.all? { |item| item.fulfillment_service != 'shipwire' }
  end
end
