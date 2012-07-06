class FulfillmentsController < ApplicationController

  def index
    @fulfillments = Fulfillment.all
  end


  def create_line_item_fulfillment
    if Fulfillment.fulfill_line_items?(current_setting,params[:order_id],params[:line_item_ids],params[:shipping_method], params[:warehouse])
      flash[:notice] = "Fulfillment request sent."
    else
      flash[:alert] = "Invalid fulfillment request."
    end
    redirect_to :back
  end

  def create_orders_fulfillment
    if Fulfillment.fulfill_orders?(current_setting,params[:order_ids], params[:shipping_method], params[:warehouse])
      flash[:notice] = "Fulfillment request sent."
    else
      flash[:alert] = "Invalid fulfillment request."
    end
    redirect_to :back
  end
end

