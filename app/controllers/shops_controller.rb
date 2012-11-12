class ShopsController < ApplicationController
  skip_before_filter :shop_exists, :only =>['create', 'new']

  def show
    @shop = current_shop
    @recent_fulfillments = @shop.fulfillments.order(:updated_at).limit(5)
  end

  def new
    @shop = Shop.new()
  end

  def edit
    @shop = current_shop
  end

  def create
    @shop = Shop.new(params[:shop])
    @shop.token = session[:shopify].token
    @shop.domain = session[:shop]
    if @shop.save
      flash[:notice] = 'Your settings have been saved.'
      redirect_to action: "show"
    else
      flash[:alert] = 'Invalid settings, was not able to save.'
      redirect_to action: "new"
    end
  end

  def update
    if current_shop.update_attributes(params[:shop])
      flash[:notice] = 'Your settings have been updated.'
      redirect_to action: "show"
    else
      flash[:alert] = 'Could not successfully update.'
      redirect_to action: "edit"
    end
  end

end
