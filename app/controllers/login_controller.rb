class LoginController < ApplicationController
  skip_around_filter :shopify_session
  skip_before_filter :shop_exists

  def index
    if params[:shop].present?
      redirect_to "/auth/shopify?shop=#{params[:shop].to_s.strip}"
    end
  end

  def finalize
    if response = request.env['omniauth.auth']
      session[:shopify] = ShopifyAPI::Session.new(params['shop'], response['credentials']['token'])
      session[:shop] = params['shop']
      redirect_to controller: 'shops', action: 'show', notice: 'Logged in'
    else
      redirect_to action: 'index', alert: 'Could not log in to Shopify store.'
    end
  end

  def logout
    reset_session
    redirect_to action: 'index', notice: 'Successfully logged out.'
  end
end