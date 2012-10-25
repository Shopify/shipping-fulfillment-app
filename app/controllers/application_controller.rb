class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :shopify_session
  before_filter :shop_exists


  private

  def valid_shipwire_credentials
    redirect_to(:controller => 'shops', :action => 'show', :alert => "You must create an account") unless current_shop.valid_credentials
  end

  def shop_exists
    puts session.has_key?(:shop)
    redirect_to(:controller => 'login', :action => 'index', :alert => "You must login.") unless session.has_key?(:shop)
  end

  def current_shop
    @shop ||= Shop.find_by_domain(session[:shop])
  end

  helper_method :current_shop
end
