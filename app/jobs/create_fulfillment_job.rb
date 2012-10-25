class CreateFulfillmentJob
  @queue = :default

  def self.perform(params, shop_domain)

    shop = Shop.find_by_domain(shop_domain)
    order = nil

    shop.shopify_session {
      order = ShopifyAPI::Order.find(params["order_id"])
    }

    params["shipping_method"] = "1D"

    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
    response = shipwire.fulfill(order.id, address_to_hash(order.shipping_address).merge({:email => order.email}), params["line_items"], generate_options(order, params))


    fulfillment = Fulfillment.new_from_params(shop, params)
    shop.fulfillments << fulfillment
    shop.save

    if response.success?
      fulfillment.success
      update_lat_long(fulfillment, response)
    else
      fulfillment.record_failure
    end
  end

  private

  def self.update_lat_long(fulfillment, response)
    %w(origin_lat origin_long destination_lat destination_long).each do |key|
      fulfillment.update_attribute(key, BigDecimal.new(response.params[key])) if response.params.has_key?(key)
    end
  end

  def self.address_to_hash(address)
    {:address1 => address.address1,
     :address2 => address.address2,
     :name => address.name,
     :company => address.company,
     :city => address.city,
     :state => address.province,
     :country => address.country,
     :zip => address.zip,
     :phone => address.phone}
  end

  def self.generate_options(order, params)
    {warehouse: '00',
      email: order.email,
      shipping_method: params["shipping_method"]
    }
  end
end