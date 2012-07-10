module ApplicationHelper

  def service_is_not_shipwire?(order)
    order.line_items.each do |item|
      return true if item.fulfillment_service != 'shipwire'
    end
    false
  end
end
