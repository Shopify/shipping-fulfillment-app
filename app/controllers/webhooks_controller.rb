class WebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_around_filter :shopify_session
  before_filter :verify_webhook, :except => 'verify_webhook'


  def order_paid
    shop_id = request.headers['x-shopify-shop-domain']
    data = ActiveSupport::JSON.decode(request.body.read)
    order_id = data["id"]
    shipping_address = data["shipping_address"]
    setting = Setting.where("shop_id = ?", shop_id).first

    ShopifyAPI::Session.new(shop_id, setting.token)
    status = Fulfillment.fulfill(order_id, shipping_address) if setting.automatic_fulfillment

    if status
      render :status => 200, :text => 'succes'
    else
      render :status => 500, :text => 'error'
    end
  end


  private

  def verify_webhook
    data = request.body.read.to_s
    hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    digest = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShipwireApp::Application.config.shopify.secret, data)).strip
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end
end

