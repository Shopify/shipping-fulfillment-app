class WebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_before_filter :setting_exists
  skip_around_filter :shopify_session
  #before_filter :verify_shopify_webhook, :except => 'verify_webhook'
  #can't use this on tests

  def order_paid
#only fulfill if paid, automatic fulfillment, and service is all shipwire or fulfill line items if there are line items that are shipwire

    # shop_id = request.headers['x-shopify-shop-domain']
    # data = ActiveSupport::JSON.decode(request.body.read)
    # order_id = data["id"]
    # shipping_address = data["shipping_address"]
    # setting = Setting.where("shop_id = ?", shop_id).first

    # ShopifyAPI::Session.new(shop_id, setting.token)
    # status = Fulfillment.fulfill(order_id, shipping_address) if setting.automatic_fulfillment

    head :ok
  end

  def uninstall_app

  end

  def order_created
    shop_id = request.headers['x-shopify-shop-domain']
    data = ActiveSupport::JSON.decode(request.body.read)
    puts data.inspect
    order = Order.new(data.merge({shopify_order_id: data['id']}))
    order.shipping_address = ShippingAddress.create(data['shipping_address'])
    line_items = data['line_items'].map do |item|
      params = item.attributes
      params[:line_item_id] = data.delete('id')
      LineItem.new(params)
    end
    order.save

    head :ok
  end

  def order_updated
    shop_id = request.headers['x-shopify-shop-domain']
    data = ActiveSupport::JSON.decode(request.body.read)
    order = Order.find(data['id'])
    order.update_attributes(data)
    order.shipping_address.update_attributes(data['shipping_address'])
    order.line_items.destroy
    order.line_items = data['line_items'].map do |item|
      params = item.attributes
      params[:line_item_id] = data.delete('id')
      LineItem.new(params)
    end
    order.save

    head :ok
  end

  def order_fulfilled
    shop_id = request.headers['x-shopify-shop-domain']
    data = ActiveSupport::JSON.decode(request.body.read)
    order = Order.find(data['id'])
    order.fulfillment_status = 'fulfilled'
    order.line_items.each {|item| item.fulfillment_status = 'fulfilled'}
    order.save

    head :ok
  end

  private

  def verify_shopify_webhook
    data = request.body.read.to_s
    hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    digest = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShipwireApp::Application.config.shopify.secret, data)).strip
    puts "HEADERHMAC = #{hmac_header}"
    puts "CALCULATEDHMAC = #{calculated_hmac}"
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end
end