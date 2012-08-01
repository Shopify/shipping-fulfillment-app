class WebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_before_filter :shop_exists
  skip_around_filter :shopify_session

  before_filter :verify_shopify_webhook
  before_filter :find_or_create_order
  before_filter :hook

  rescue_from Exception {|exception| head :ok } unless Rails.env == 'test'

  def create
    case @hook
      when 'orders/create'
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
    Resque.enqueue(OrderCreateJob, sanitized_params, @shop.id)
  end

  def order_updated
    Resque.enqueue(OrderUpdateJob, params['line_items'])
  end

  def order_cancelled
    Resque.enqueue(OrderCancelJob, @order.id, params['cancelled_at'], params['cancel_reason'])
  end

  def order_fulfilled
    Resque.enqueue(OrderFulfillJob, @order.id)
  end

  def order_paid
    if @order.shop.automatic_fulfillment?
      Resque.enqueue(OrderPaidJob, @order.id, @shop.id, params['shipping_lines'])
    end
    @order.update_attribute(:financial_status, 'paid')
  end

  def find_or_create_order
    @shop = Shop.find_by_domain(shop_domain)
    if @shop.orders.where('shopify_order_id = ?', params['id']).blank?
      @hook = 'orders/create'
    else
      @order = @shop.orders.find_by_shopify_order_id(params['id'])
    end
  end

  def verify_shopify_webhook
    data = request.body.read.to_s
    digest = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShipwireApp::Application.config.shopify.secret, data)).strip
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end

  def sanitized_params
    params.except(:action, :controller) # json webhook data does not have root node
  end

  def hook
    @hook = request.headers['HTTP_X_SHOPIFY_TOPIC']
  end

  def shop_domain
    request.headers['HTTP_X_SHOPIFY_SHOP_DOMAIN']
  end

  def hmac_header
    request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
  end

end