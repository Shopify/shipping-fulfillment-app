class ShopsController < ApplicationController
  skip_before_filter :shop_exists, :only =>['show','create']

  def show
    current_shop.present? ? @shop = current_shop : @shop = Shop.new
  end

  def create
    @shop = Shop.new(params[:shop])
    @shop.token = session[:shopify].token
    @shop.domain = session[:shop]
    if @shop.save
      Resque.enqueue(OrderCollectorJob, @shop)
      redirect_to orders_path, notice: 'Your settings have been saved.'
    else
      redirect_to shop_path, alert: 'Invalid settings, was not able to save.'
    end
  end

  def update
    if current_shop.update_attributes(params.slice(:login, :password, :automatic_fulfillment))
      redirect_to shop_path, notice: 'Your settings have been updated.'
    else
      puts "ERRORS: #{@shop.errors.inspect}"
      redirect_to shop_path, alert: 'Could not successfully update!'
    end
  end

end
