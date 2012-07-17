class OrdersController < ApplicationController

  # TODO: constant for per page
  before_filter :get_page, :except => [:shipping_rates]

  PER_PAGE = 10

  def index
    @page_count = (Order.all.count/(PER_PAGE.to_f)).ceil
    set_order_pagination(params)
    @orders = Order.get_paginated_orders(current_setting, @page)
  end


  def show
    @order = Order.find(params[:id]) ## not shopify_order_id, might need to fix in views
    @page_count = (@order.line_items.count/(PER_PAGE.to_f)).ceil
    set_item_pagination(params)
    @line_items = LineItem.get_paginated_line_items(current_setting, order_id, page)
  end

  def shipping_rates
    @rates = ShippingRates.find_order_rates(params[:shopify_order_id])
    respond_to :js
  end

  private

  def set_order_pagination
    @page = params[:page] || 1
    if @page < 1 || @page > @pagecount
      @page = 1
    end
  end

  def page_count(value)
    return (value/PER_PAGE.to_f).ceil
  end
end