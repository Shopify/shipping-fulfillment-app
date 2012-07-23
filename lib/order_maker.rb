module OrderMaker

  def self.create_order(params,setting)
    options = order_options(params)
    options['shipping_address_attributes'] = get_shipping_attributes(params)
    options['line_items_attributes'] = get_line_items_attributes(params)
    options['setting_id'] = setting.id
    create(options)
  end

  def self.order_options(params)
    options = params.slice(*Order.column_names)
    options['shopify_order_id'] = params['id']
    options
  end

  def self.get_shipping_attributes(params)
    options = params.slice(*ShippingAddress.column_names)
    options
  end

  def self.get_line_items_attributes(params)
    params['line_items'].map do |item|
      options = item.slice(*LineItem.column_names)
      options['line_item_id'] = item['id']
      options
    end
  end
end