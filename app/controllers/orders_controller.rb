class OrdersController < ApplicationController

  PER_PAGE = 10

  before_filter :get_page, :except => [:shipping_rates]

  def index
    @orders = current_setting.orders.paginate(:page => @page, :per_page => PER_PAGE)
  end


  def show
    @order = current_setting.orders.where()
    @line_items = @order.line_items.paginate(:page => @page, :per_page => PER_PAGE)
  end

  def shipping_rates
    @rates = ShippingRates.find_order_rates(params[:shopify_order_id])
    respond_to :js
  end

  private

  def get_page
    @page = params[:page] || 1
  end

end