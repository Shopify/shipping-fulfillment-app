class OrdersController < ApplicationController

  # TODO: constant for per page
  before_filter :get_page, :except => [:shipping_rates]

  ITEMS_PER_PAGE = 10

  def index
    @page_count = page_count(ShopifyAPI::Order.all.count)
    @orders = get_paginated_orders
  end


  def show
    @order = ShopifyAPI::Order.find(params[:id])
    @page_count = page_count(@order.line_items.count)
    @line_items = get_paginated_line_items
  end

  def shipping_rates
    @rates = ShippingRates.find_order_rates(params[:shopify_order_id])
    respond_to :js
  end

  private

  ## No model to put these in, eventually can put them in orders model
  def get_page
    @page = params[:page] || 1
  end

  def page_count(value)
    return (value/ITEMS_PER_PAGE.to_f).ceil
  end

  def get_paginated_orders
    if @page <= @page_count+1 && @page > 0 # TODO: before filter as well
      ShopifyAPI::Order.find(:all, :params => {:limit => 10, :page => @page}) # TODO: move to index
    else
      @page = 1
      get_paginated_orders
    end
  end

  def get_paginated_line_items
    per_page = ITEMS_PER_PAGE # TODO: ditto above
    if @page < @page_count+1 && @page > 0
      return @order.line_items[(@page-1)*per_page, per_page]
    elsif @page == @page_count
      return @order.line_items[((@page-1)*per_page)..-1]
    else
      flash[:alert] = "Invalid page number, you have been redirected to the first page."
      @page = 1
      get_paginated_line_items
    end
  end
end

