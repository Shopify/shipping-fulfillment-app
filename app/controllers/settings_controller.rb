class SettingsController < ApplicationController
  def new
    if Setting.present?
      @setting = Setting.new
    else
      redirect_to :action => 'show'
    end
  end

  def create 
    @setting = Setting.build(params[:setting].merge({token: session[:shopify].token}))
    if @setting.save
      redirect_to @setting, :success => "Your settings have been saved."
    else
      render action:"new", :errors => "Invalid settings, was not able to save."
    end
  end 

  def show
    current_setting
  end

  def edit
    current_setting
  end

  def update
    if current_setting.update_attributes(params[:setting])
      render action:"show", :success => "Your settings have been updated."
    else
      render action: 'edit', :errors => "Could not successfully update!"
    end
  end
end
