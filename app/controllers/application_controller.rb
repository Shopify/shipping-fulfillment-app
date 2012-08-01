class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :shopify_session
  before_filter :shop_exists


  private

  def shop_exists
    redirect_to(login_path) unless session.has_key?(:shop)
  end

  def current_shop
    @shop ||= Shop.find_by_domain(session[:shop])
  end

  helper_method :current_shop
end
