class ShopsController < ApplicationController
  skip_before_filter :shop_exists, :only =>['new','create']

  # need to merge new and edit view into show view
  def show
    @shop = current_shop #might be empty array
  end

  def create
    @shop = Shop.new(params[:shop].merge({token: session[:shopify].token}))
    if @shop.save
      redirect_to @shop, :notice => "Your settings have been saved."
    else
      render action:"new", :alert => "Invalid settings, was not able to save."
    end
  end

  def update
    if current_shop.update_attributes(params[:shop])
      redirect_to '/shops', :notice => "Your settings have been updated."
    else
      redirect_to '/shops', :alert => "Could not successfully update!"
    end
  end

end
