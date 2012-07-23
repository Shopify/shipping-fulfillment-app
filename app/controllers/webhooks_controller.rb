class WebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_before_filter :setting_exists
  skip_around_filter :shopify_session

  before_filter :verify_shopify_webhook
  before_filter :sanitized_order_webhook_params
  before_filter :find_or_create_order

  rescue_from Exception do
    head :ok
  end

  def create
    puts "here"
    case request['HTTP_X_SHOPIFY_TOPIC']
      when 'orders/create'
        puts "yay"
        order_created
      when 'orders/updated'
        order_updated
      when 'orders/paid'
        order_paid
      when 'orders/cancelled'
        order_cancelled
      when 'orders/fulfilled'
        order_fulfilled
    end
    head :ok
  end

  private

  def order_created
    Resque.enqueue(OrderCreateJob, params, @setting)
  end

  def order_updated
    Resque.enqueue(OrderUpdateJob, params['line_items'])
  end

  def order_cancelled
    Resque.enqueue(OrderCancelJob, @order, params['cancelled_at'], params['cancel_reason'])
  end

  def order_fulfilled
    Resque.enqueue(OrderFulfillJob, @order)
  end

  def order_paid
    if @order.setting.automatically_fulfill
      Resque.enqueue(OrderPaidJob, @order, params['id'], params['shipping_method'])
    end
    @order.update_attribute(:financial_status, "paid")
  end


  def find_or_create_order
    @setting = Setting.where("shop_id = ?",request.headers['HTTP_X_SHOPIFY_SHOP_DOMAIN'])
    if request.headers['HTTP_X_SHOPIFY_TOPIC'] != 'orders/create' && @setting.orders.where('shopify_order_id = ?', params['id']).blank?
      create_order
    else
      @order = @setting.orders.where('shopify_order_id = ?', params['id']).first
    end
  end


  def verify_shopify_webhook
    data = request.body.read.to_s
    hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
    digest = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShipwireApp::Application.config.shopify.secret, data)).strip
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end

  def sanitized_order_webhook_params
    params.except(:action, :controller) # json webhook data does not have root node
  end
end