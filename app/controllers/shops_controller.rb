class ShopsController < ApplicationController
  skip_before_filter :shop_exists, :only =>['new','create']

  def new # TODO: clean this process up
    if Shop.exists?
      redirect_to :action => 'show'
    else
      @shop = Shop.new
    end
  end

  def create
    @shop = Shop.build(params[:shop].merge({token: session[:shopify].token}))
    if @shop.save
      redirect_to @shop, :notice => "Your settings have been saved."
    else
      render action:"new", :alert => "Invalid settings, was not able to save."
    end
  end

  def show # TODO: merge show, edit and new
    current_shop
  end

  def edit
    current_shop
  end

  def update
    if current_shop.update_attributes(params[:shop])
      redirect_to '/shops', :notice => "Your settings have been updated."
    else
      redirect_to '/shops', :alert => "Could not successfully update!"
    end
  end

end
