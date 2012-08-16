class VariantsController < ApplicationController

  before_filter :valid_shipwire_credentials

  def index
    @management = params[:management] || 'shipwire'
    @page = params[:page].to_i || 1
    @variants, @pages = Variant.filter_and_paginate_variants(@management, @page)
  end

  def show
    @product_title = params[:product_title]
    @variant = current_shop.variants.find_by_shopify_variant_id(params[:id])
    @address = @variant.last_fulfilled_order_address
  end

  def update
    management = params.delete('management')
    @ids, @skus, @failures = Variant.update_skus(management, params.except(:action,:controller,:format))
  end

  # need to toggle create and destroy between different filters
  def create
    failures = Variant.batch_create_variants(current_shop, params[:shopify_variant_ids])
    if failures == 0
      redirect_to variants_path, notice: "The variant is now managa by shipwire."
    else
      redirect_to variants_path, alert: pluralize(failures, 'Variant') + "did not manage to save, please check the sku."
    end
  end

  def destroy
    variant = current_shop.variants.find_by_shopify_variant_id(params[:id])
    shopify_variant = ShopifyAPI::Variant.find(variant.shopify_variant_id)
    shopify_variant.update_attribute('inventory_management','shopify')
    variant.destroy
    redirect_to variants_path, notice: "The variant will no longer be managed by shipwire."
  end

end