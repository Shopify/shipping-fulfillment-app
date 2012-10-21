class FulfillmentsController < ApplicationController

  before_filter :valid_shipwire_credentials

  def index
    @fulfillments = current_shop.fulfillments.all
  end

  def show
    @fulfillment = current_shop.fulfillments.find(params[:id])
  end

end

