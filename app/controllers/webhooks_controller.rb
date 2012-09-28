class WebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_before_filter :shop_exists
  skip_around_filter :shopify_session

  before_filter :sanitized_params
  before_filter :verify_shopify_webhook
  before_filter :verify_shipwire_service, :only => [:fulfillment]
  before_filter :hook

  rescue_from ActionController::RoutingError do |exception|
    head :ok
  end

  def order
    find_or_create_order
    puts @params
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

  def fulfillment
    case @hook
    when 'fulfillments/create'
      fulfillment_created
    when 'fulfillments/update'
      fulfillment_updated
    end
    head :ok
  end

  def uninstalled
    case @hook
    when 'app/uninstalled'
      app_uninstalled
    end
    head :ok
  end

  private

  def order_created
    Resque.enqueue(OrderCreateJob, @params, @shop.id)
  end

  def order_updated
    Resque.enqueue(OrderUpdateJob, @params[:line_items])
  end

  def order_cancelled
    Resque.enqueue(OrderCancelJob, @order.id, @params[:cancelled_at], @params[:cancel_reason])
  end

  def order_fulfilled
    Resque.enqueue(OrderFulfillJob, @order.id)
  end

  def order_paid
    if @order.shop.automatic_fulfillment?
      Resque.enqueue(OrderPaidJob, @order.id, @shop.id, @params[:shipping_lines])
    end
    @order.update_attribute(:financial_status, 'paid')
  end

  def fulfillment_created
    raise FulfillmentError unless Fulfillment.where('shopify_fulfillment_id = ?', @params[:id]).blank?
    Resque.enqueue(CreateFulfillmentJob, @params, shop_domain)
  end

  def find_or_create_order
    @shop = Shop.find_by_domain(shop_domain)
    if @shop.orders.where('shopify_order_id = ?', @params['id']).blank?
      @hook = 'orders/create'
    else
      @order = @shop.orders.find_by_shopify_order_id(@params['id'])
    end
  end

  def app_uninstalled
    Resque.enqueue(AppUninstalledJob, shop_domain)
  end

  def verify_shopify_webhook
    puts "HMAC: #{hmac}"
    data = request.body.read.to_s
    digest = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShipwireApp::Application.config.shopify.secret, data)).strip
    head :unauthorized unless calculated_hmac == hmac
    request.body.rewind
  end

  def verify_shipwire_service
    head :ok unless @params["service"] == 'shipwire-app'
  end

  def sanitized_params
    @params = params.except(:action, :controller).with_indifferent_access
  end

  def hook
    @hook = request.headers['HTTP_X_SHOPIFY_TOPIC']
  end

  def shop_domain
    request.headers['HTTP_X_SHOPIFY_SHOP_DOMAIN']
  end

  def hmac
    request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
  end

end