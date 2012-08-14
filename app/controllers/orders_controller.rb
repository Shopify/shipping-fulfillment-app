class OrdersController < ApplicationController
  respond_to :html, except: [:shipping_rates]
  respond_to :js, only: [:shipping_rates]
  before_filter :valid_shipwire_credentials

  PER_PAGE = 10

  before_filter :get_page, {except: [:shipping_rates]}

  def index
    @orders = current_shop.orders.paginate({page: @page, per_page: params[:limit] || PER_PAGE})
  end

  def show
    @order = current_shop.orders.find(params[:id])
    @line_items = @order.line_items.paginate({page: @page, per_page: params[:limit] || PER_PAGE})
  end

  def shipping_rates
    @rates = OrderShippingRates.new(current_shop.credentials, params[:id]).fetch_rates if Rails.env == 'production'
  end

  private

  def get_page
    @page = params[:page] || 1
  end

end