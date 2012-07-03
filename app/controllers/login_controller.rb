class LoginController < ApplicationController
  skip_around_filter :shopify_session

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
      flash[:success] = "Logged in"
      redirect_to return_address
      session[:return_to] = nil
    else
      flash[:errors] = "Could not log in to Shopify store."
      redirect_to :action => 'index'
    end
  end
  
  def logout
    session[:shopify] = nil
    flash[:success] = "Successfully logged out."
    
    redirect_to :action => 'index'
  end
  
  protected
  
  def return_address
    session[:return_to] || '/orders'
  end

end
