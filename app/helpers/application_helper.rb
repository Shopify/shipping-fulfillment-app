module ApplicationHelper
  def service_is_not_shipwire?(order)
    order.line_items.all? { |item| item.fulfillment_service != 'shipwire' }
  end

  def label_style_helper(status)
    case status
    when "success"
      "label-success"
    when "pending"
    else
      "label-error"
    end
  end
end
