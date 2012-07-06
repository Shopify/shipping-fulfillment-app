class FulfillmentsController < ApplicationController
  def create_line_item_fulfillment
    if Fulfillment.fulfill_line_items? (current_setting, params[:order_id], params[:line_item_ids], params[:shipping_method], )
      flash[:notice] = "Fulfillment request sent."
    else
      flash[:alert] = "Invalid fulfillment request."
    end
    redirect_to :back
  end

  def create_orders_fulfillment
    if Fulfillment.fulfill_orders? (current_setting,)
      flash[:notice] = "Fulfillment request sent."
    else
      flash[:alert] = "Invalid fulfillment request."
    end
    redirect_to :back
  end
end

