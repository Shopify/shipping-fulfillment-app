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
    redirect_to :action => 'index', :errors => 'Unable to sync.'
    end
  end

  def edit
    @product_title = params[:product_title]
    @variant = ShopifyAPI::Variant.find(params[:id])

    case @variant.inventory_management

    when 'shipwire'
      @inventory_services = ['shipwire','shopify','other']
    when 'shopify'
      @inventory_services = ['shopify','shipwire','other']
    else
      @inventory_services = ['other','shipwire','shopify']
    end
  end

  ## need params sku and inventory management
  def update
    shopify_variant = ShopifyAPI::Variant.find(params[:id])
    begin 
      if Variant.where('variant_id = ?', shopify_variant.id).present?
        variant = Variant.where('variant_id = ?', shopify_variant.id).first
        variant.activated = true unless params[:inventory_management] != 'shipwire'
        variant.sku = params[:sku]
        raise StandardError.new('The variant can only be updated with a valid sku.') unless variant.save
      elsif params[:inventory_management] == 'shipwire'
        variant = Variant.new(variant_id: shopify_variant.id, setting_id: session[:setting_id], activated: true, sku: params[:sku])
        raise StandardError.new('The variant can only be updated with a valid sku.') unless variant.save
      else
        raise StandardError.new('The variant must have a good sku.') unless Variant.good_sku?(sku)
      end
      shopify_variant.inventory_management = params[:inventory_management] unless params[:inventory_management] == 'other'
      shopify_variant.sku = params[:sku]
      shopify_variant.save
    rescue StandardError => e
      flash[:errors] = e.message
      redirect_to variants_path
    end
  end

  #eventually shopify will also be given/able to request the inventories from the app via variant_id
  def give_inventory
    stock_levels = Variant.where('variant_id = ?', params[:variant_id]).inventory
    render json: stock_levels
    render status: 500
  end
end