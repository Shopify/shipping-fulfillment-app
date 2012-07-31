class FulfillmentsController < ApplicationController

  def index
    @fulfillments = current_shop.fulfillments.all
  end

  def show
    @fulfillment = current_shop.fulfillments.find(params[:id])
  end


  def create
    params[:shopify_order_ids] ||= [params[:shopify_order_id]]
    success = Fulfillment.fulfill(current_shop, params)
    if success
      flash[:notice] = "Your fulfillment request has been sent."
    else
      flash[:alert] = "There were errors with your fulfillment request that prevented it from being sent."
    end
    redirect_to action: 'index'
  end

end

