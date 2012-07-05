class OrdersController < ApplicationController
  def index
    params[:page] = 1 unless params.has_key? :page 
    @page = params[:page].to_i

    @page_count = (ShopifyAPI::Order.all.count/10.0).ceil
    @orders = get_paginated_orders(params[:page].to_i)
  end


  def show
    params[:page] = 1 unless params.has_key? :page
    @page = params[:page].to_i

    @order = ShopifyAPI::Order.find(params[:id])
    @page_count = (@order.line_items.count/10.0).ceil
    @line_items = get_paginated_line_items
  end




  private
  
  def get_paginated_orders(page)
    ShopifyAPI::Order.find(:all, :params => {:limit => 10, :page => page})
  end

  def get_paginated_line_items
    per_page = 10
    if @page < @page_count+1 && @page > 0
      return @order.line_items[(@page-1)*per_page, per_page]
    elsif @page == @page_count
      return @order.line_items[((page-1)*per_page)..-1]
    else
      flash[:errors] = "Invalid page number, you have been redirected to the first page."
      @page = 1
      get_paginated_line_items
    end
  end
end

