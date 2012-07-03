class VariantsController < ApplicationController
  def index
    @page_count = 1
    @products = ShopifyAPI::Product.all
  end

  def show 
     @product_title = params[:product_title] 
     @variant = ShopifyAPI::Variant.find(params[:id])
  end

  #move to model
  def sync
    params[:ids].each do |id|
      status = Variant.sync(id, session[:shop])
      flash[:errors] unless status
      redirect_to :action => 'index'
    end
  end

  def edit
    @product_title = params[:product_title]
    @variant = ShopifyAPI::Variant.find(params[:id])
    @variant.inventory_management == 'shipwire' ? @other_service = 'other': @other_service = 'shipwire' 
  end

  # def update
  #   if Variant.where('variant_id = ?', params[:id]).empty?
  #     @variant = Variant.new
  #     @variant.id = params[:id]
  #     @variant.
  #   else
  #     @variant = Variant.where('variant_id = ?', params[:id]).first
  #     @variant.update_attributes(params[:variant])
  #   end
  #   puts params.inspect
  #   @variant = Variant.find_by_id(params[:id])
  #   if @variant.update_attributes(params[:variant])
  #     flash[:success] = "Product Variant Update Successful!"
  #   else
  #     flash[:errors] = "Product Variant cannot save. Make sure Sku and account information are correct."
  #   end
  #   render action: 'index'
  # end

  # def unsync
  #   params[:ids].each do |id|
  #     puts id
  #     redirect_to :action => 'index'
  #   end 
  # end

  #eventually shopify will also be given/able to request the inventories from the app via variant_id
  def give_inventory
    stock_levels = Variant.find_by_id(params[:variant_id]).inventory
    render json: stock_levels unless stock_levels == -1
    render status: 500
  end

  private

  #hard to paginate because need product and variant for view
  def get_product_variants(page)
    per_page = 10
    if page < @page_count+1 && page > 0
      puts "need to build"
    end
    flash[:errors] = "Invalid page number, you have been redirected to the first page."
    @page = 1
  end
end