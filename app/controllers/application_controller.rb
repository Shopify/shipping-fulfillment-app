class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :shopify_session
  before_filter :setting_exists

  private

  def setting_exists
    redirect_to(login_path) unless Setting.exists?
  end

  def current_setting 
    @setting ||= Setting.where('shop_id = ?', ShopifyAPI::Shop.current.myshopify_domain).first
  end

  helper_method :current_setting
end
