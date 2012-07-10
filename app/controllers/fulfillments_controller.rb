class FulfillmentsController < ApplicationController

  def index
    @fulfillments = Fulfillment.all
  end

  def show
    @fulfillment = Fulfillment.find(params[:id])
  end

  # current_setting, shopify_order_id, line_item_ids, shipping_method, warehouse
  # current_setting, shopify_order_ids, shipping_method, warehouse  <= note the difference between id and ids

  def create
    puts params.inspect
    throw RuntimeError
    success = Fulfillment.fulfill(current_setting, params)
    if success
      flash[:notice] = "Your fulfillment request has been sent."
    else
      flash[:notice] = "There were errors with your fulfillment request that prevented it from being sent."
    end
    redirect_to action: :index
  end

  def get_paginated_fulfillments
    #eventually paginate fulfillments
  end
end

