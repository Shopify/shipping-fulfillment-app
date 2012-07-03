class SettingsController < ApplicationController
  def new
    if Setting.where('shop_id = ?', ShopifyAPI::Shop.current.myshopify_domain).empty?
      @setting = Setting.new
    else
      redirect_to :action => 'show'
    end
  end

  def create 
    @setting = Setting.build(params[:setting].merge({token: session[:shopify].token}))
    if @setting.save
      session[:setting_id] = @setting.id
      flash[:success] = "Your settings have been saved."
      redirect_to @setting
    else
      flash[:errors] = "Invalid settings, was not able to save."
      render action:"new"
    end
  end 

  def show
    @setting = Setting.where('shop_id = ?', session[:shop]).first
  end

  def edit
    @setting = Setting.where('shop_id = ?', session[:shop]).first
  end

  def update
    @setting = Setting.where('shop_id = ?', session[:shop]).first
    if @setting.update_attributes(params[:setting])
      flash[:success] = "Your settings have been updated."
      render action:"show"
    else
      flash[:errors] = "Could not successfully update!"
      render action: 'edit'
    end
  end
end
