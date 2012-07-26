class ShopsController < ApplicationController
  skip_before_filter :shop_exists, :only =>['new','create']

  # need to merge new and edit view into show view
  def show
    current_shop.present? ? @shop = current_shop : @shop = Shop.new
  end

  def create
    @shop = Shop.new(params[:shop].merge({token: session[:shopify].token, domain: session[:shop]}))
    if @shop.save
      redirect_to shop_path, :notice => "Your settings have been saved."
    else
      redirect_to shop_path, :alert => "Invalid settings, was not able to save."
    end
  end

  def update
    if current_shop.update_attributes(params[:shop])
      redirect_to shop_path, :notice => "Your settings have been updated."
    else
      redirect_to shop_path, :alert => "Could not successfully update!"
    end
  end

end
