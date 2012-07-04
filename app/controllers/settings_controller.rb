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
      redirect_to @setting, :success => "Your settings have been saved."
    else
      render action:"new", :errors => "Invalid settings, was not able to save."
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
      render action:"show", :success => "Your settings have been updated."
    else
      render action: 'edit', :errors => "Could not successfully update!"
    end
  end
end
