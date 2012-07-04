class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :shopify_session

  private

  def current_setting 
    @setting ||= Setting.where('shop_id = ?', session[:shop]).first if session[:shop]
  end

  helper_method :current_setting
end
