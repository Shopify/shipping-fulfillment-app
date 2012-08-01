class VariantsController < ApplicationController
  def index
    @products = ShopifyAPI::Product.all
  end

  def show
    @product_title = params[:product_title]
    @variant = current_shop.variants.find_by_shopify_variant_id(params[:id]) || ShopifyAPI::Variant.find(params[:id])
  end

  def create
    if current_shop.variants.create(shopify_variant_id: params[:shopify_variant_id], sku: params[:sku], title: params[:title])
      redirect_to variants_path, notice: "The variant is now managa by shipwire."
    else
      redirect_to variants_path, alert: "The variant is invalid and is not managed by shipwire."
    end

  end

  def destroy
    variant = current_shop.variants.find_by_shopify_variant_id(params[:id])
    shopify_variant = ShopifyAPI::Variant.find(variant.shopify_variant_id)
    shopify_variant.update_attribute('inventory_management','shopify')
    variant.destroy
    redirect_to variants_path, notice: "The variant will no longer be managed by shipwire."
  end

  # TODO: eventually shopify will also be given/able to request the inventories from the app via variant_id
  # def give_inventory
  #   stock_levels = Variant.where('variant_id = ?', params[:variant_id]).first.quantity
  #   render json: stock_levels
  # end
end