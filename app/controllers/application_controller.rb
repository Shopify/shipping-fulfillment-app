class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :shopify_session
  before_filter :shop_exists

  private

  def shop_exists
    redirect_to(login_path) unless Shop.exists?
  end

  def current_shop
    @shop ||= Shop.where('domain = ?', ShopifyAPI::Shop.current.myshopify_domain).first
  end

  helper_method :current_shop
end
