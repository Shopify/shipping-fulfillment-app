class OrdersController < ApplicationController

  # TODO: constant for per page

  def index
    params[:page] = 1 unless params.has_key? :page # TODO: before filter
    @page = params[:page].to_i
    @page_count = (ShopifyAPI::Order.all.count/10.0).ceil # TODO: constant for page length
    @orders = get_paginated_orders
  end


  def show
    params[:page] = 1 unless params.has_key? :page
    @page = params[:page].to_i
    @order = ShopifyAPI::Order.find(params[:id])
    @page_count = (@order.line_items.count/10.0).ceil
    @line_items = get_paginated_line_items
  end

  def shipping_rates
    @rates = ShippingRates.find_order_rates(params[:shopify_order_id])
    respond_to :js
  end

  private

  ## No model to put these in, eventually can put them in orders model
  
  def get_paginated_orders
    if @page <= @page_count+1 && @page > 0 # TODO: before filter as well
      ShopifyAPI::Order.find(:all, :params => {:limit => 10, :page => @page}) # TODO: move to index
    else
      @page = 1
      get_paginated_orders
    end
  end

  def get_paginated_line_items
    per_page = 10 # TODO: ditto above
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

