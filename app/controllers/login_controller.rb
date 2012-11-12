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
      if current_shop
        flash[:notice] = 'Logged in'
        redirect_to controller: 'shops', action: 'show'
      else
        flash[:notice] = 'Add your Shipwire credentials.'
        redirect_to controller: 'shops', action: 'new'
      end
    else
      flash[:alert] = 'Could not log in to Shopify store.'
      redirect_to action: 'index'
    end
  end

  def logout
    reset_session
    flash[:notice] = 'Successfully logged out.'
    redirect_to action: 'index'
  end
end