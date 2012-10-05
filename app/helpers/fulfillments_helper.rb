module FulfillmentsHelper
  def tracking_link(fulfillment)
    if fulfillment.tracking_number
      link_to @fulfillment.tracking_number, @fulfillment.tracking_link
    else
      "No Tracking Number"
    end
  end


  def shipping_method_in_words(fulfillment)
    case fulfillment.shipping_method
    when "1D"
      "One Day"
    when "2D"
      "Two Day"
    when "GD"
      "Ground"
    when "FT"
      "Freight"
    when "INTL"
      "International"
    end

  end
end
