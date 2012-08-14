class FulfillmentsController < ApplicationController

  before_filter :valid_shipwire_credentials

  def index
    @fulfillments = current_shop.fulfillments.all
  end

  def show
    @fulfillment = current_shop.fulfillments.find(params[:id])
  end


  def create
    params[:order_ids] ||= [params[:order_ids]]
    success = Fulfillment.fulfill(current_shop, params)
    if success
      flash[:notice] = "Your fulfillment request has been sent."
    else
      flash[:alert] = "There were errors with your fulfillment request that prevented it from being sent."
    end
    redirect_to action: 'index'
  end

end

