class VariantsController < ApplicationController
  def index
    @products = ShopifyAPI::Product.all
  end

  def show
     @product_title = params[:product_title]
     @variant = ShopifyAPI::Variant.find(params[:id])
  end

  ## need params sku and inventory management
  ## need to push most of this to helpes and model, conditional validators
  def create
    redirect_to(variants_path, alert: "The sku is not recognized by Shipwire. Please enter a valid sku.") unless Variant.good_sku? params[:sku]
    if current_shop.variants.create(shopify_variant_id: params[:shopify_variant_id], sku: params[:sku], management: 'shipwire')
      redirect_to variants_path, notice: "The variants inventory will now be managed by shipwire."
    else
      redirect_to variants_path, alert: "The variant is invalid and is not managed by shipwire."
    end

  def delete
    @variant = current_shop.variants.find(params[:id])
    @variant.destroy
  end

  #eventually shopify will also be given/able to request the inventories from the app via variant_id
  def give_inventory
    stock_levels = Variant.where('variant_id = ?', params[:variant_id]).inventory
    render json: stock_levels
    render status: 500
  end
end