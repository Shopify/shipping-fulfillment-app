class ShopsController < ApplicationController
  skip_before_filter :shop_exists, :only =>['show','create']

  def show
    current_shop.present? ? @shop = current_shop : @shop = Shop.new
  end

  def create
    if @shop = Shop.create(params[:shop].merge({token: session[:shopify].token, domain: session[:shop]}))
      redirect_to shop_path, notice: 'Your settings have been saved.'
    else
      redirect_to shop_path, alert: 'Invalid settings, was not able to save.'
    end
  end

  def update
    if current_shop.update_attributes(params[:shop])
      redirect_to shop_path, notice: 'Your settings have been updated.'
    else
      redirect_to shop_path, alert: 'Could not successfully update!'
    end
  end

end
