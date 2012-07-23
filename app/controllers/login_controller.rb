class LoginController < ApplicationController
  skip_around_filter :shopify_session
  skip_before_filter :shop_exists

  def index
    if params[:shop].present?
      redirect_to authenticate_path(:shop => params[:shop])
    end
  end

  def authenticate
    if params[:shop].present?
      redirect_to "/auth/shopify?shop=#{params[:shop].to_s.strip}"
    else
      redirect_to return_address
    end
  end

  def finalize
    if response = request.env['omniauth.auth']
      sess = ShopifyAPI::Session.new(params['shop'], response['credentials']['token'])
      session[:shopify] = sess
      session[:shop] = params['shop']
      flash[:notice] = "Logged in"
      redirect_to :controller => "shops", :action => "new"
      session[:return_to] = nil
    else
      redirect_to :action => 'index', :alert => "Could not log in to Shopify store."
    end
  end

  def logout
    session[:shopify] = nil
    redirect_to :action => 'index', :notice => "Successfully logged out."
  end
end
