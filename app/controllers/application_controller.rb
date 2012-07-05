class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :shopify_session

  private

  def current_setting 
    @setting ||= Setting.where('shop_id = ?', ShopifyAPI::Shop.current.myshopify_domain).first
  end

  helper_method :current_setting
end
