class ShopsController < ApplicationController
  skip_before_filter :shop_exists, :only =>['create', 'new']

  def show
    @shop = current_shop
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
      # Resque.enqueue(OrderCollectorJob, @shop)
      render action: "show", notice: 'Your settings have been saved.'
    else
      render action: "new", alert: 'Invalid settings, was not able to save.'
    end
  end

  def update
    if current_shop.update_attributes(params[:shop])
      redirect_to shop_path, notice: 'Your settings have been updated.'
    else
      render action: "edit", alert: 'Could not successfully update!'
    end
  end

end
