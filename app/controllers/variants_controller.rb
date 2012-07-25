class VariantsController < ApplicationController
  def index
    @products = ShopifyAPI::Product.all
  end

  def show
     @product_title = params[:product_title]
     @variant = ShopifyAPI::Variant.find(params[:id])
  end

  def edit
    @product_title = params[:product_title]
    @variant = ShopifyAPI::Variant.find(params[:id])
    @inventory_services = get_inventory_services(@variant.inventory_management)
  end

  ## need params sku and inventory management
  ## need to push most of this to helpes and model, conditional validators
  def update
    shopify_variant = ShopifyAPI::Variant.find(params[:id])
    begin
      if Variant.where('variant_id = ?', shopify_variant.id).present?
        variant = Variant.where('variant_id = ?', shopify_variant.id).first
        variant.activated = true unless params[:inventory_management] != 'shipwire'
        variant.sku = params[:sku]
        raise StandardError.new('The variant can only be updated with a valid sku.') unless variant.save
      elsif params[:inventory_management] == 'shipwire'
        variant = Variant.new(variant_id: shopify_variant.id, shop_id: current_shop.id, activated: true, sku: params[:sku])
        # TODO: instead of raising add validations and display errors
        raise StandardError.new('The variant can only be updated with a valid sku.') unless variant.save
      else
        raise StandardError.new('The variant must have a good sku.') unless Variant.good_sku?(sku) # TODO: happen earlier?
      end
      # TODO: move to the variant model, after_save
      shopify_variant.inventory_management = params[:inventory_management] unless params[:inventory_management] == 'other'
      shopify_variant.sku = params[:sku]
      shopify_variant.save
    rescue StandardError => e
      redirect_to variants_path, :alert => e.message
    end
  end

  #eventually shopify will also be given/able to request the inventories from the app via variant_id
  def give_inventory
    stock_levels = Variant.where('variant_id = ?', params[:variant_id]).inventory
    render json: stock_levels
    render status: 500
  end


  private

  # TODO: remove this
  def get_inventory_services(variant_service)
    case variant_service

    when 'shipwire'
      return ['shipwire','shopify','other']
    when 'shopify'
      return ['shopify','shipwire','other']
    else
      return ['other','shipwire','shopify']
    end
  end
end