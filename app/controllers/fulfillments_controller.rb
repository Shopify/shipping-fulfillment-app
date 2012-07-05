class FulfillmentsController < ApplicationController
  def create
    if (params.has_key? :orders) && (Fulfillment.fulfill(session[:shop], params[:orders], params[:shipping_method], params[:tracking_number]))
      flash[:notice] = "Order fulfillment request successfully sent."
    elsif (params.has_key? :items) && (Fulfillment.fulfill(session[:shop], [params[:id]], params[:shipping_method], params[:tracking_number], params[:items]))     
      flash[:notice] = "Line Item fulfillment request successfully sent."      
    else
      flash[:alert] = "Invalid request."
    end
    redirect_to orders_url
  end
end

