module OrdersHelper

  # Look into this and see if you should be using Enumerable#any?
  # Currently this will break upon the first item it hits (which isn't wrong, just noisier than needed)
  def shipwire_fulfillable? (shopify_order)
    shopify_order.line_items.each do |item|
      return true if item.fulfillment_service == "shipwire"
    end
    false
  end


  # Maybe these can just be class Variables LIKE_THIS
  def warehouse_options
    [['Optimized','00'],['CHI', 'Chicago'],['LAX', 'Los Angeles'],['REN', 'Reno'],['VAN', 'Vancouver'],['TOR', 'Toronto'],['UK', 'United Kingdom']]
  end

  def shipping_options
    [['1 Day Service','1D'],['2 Day Service','2D'],['Ground Service','GD'],['Freight Service', 'FT'],['International', 'INTL']]
  end

  def disabled?(item)
    item.fulfillment_status == 'fulfilled' || 'shipwire' != item.fulfillment_service
  end

end
