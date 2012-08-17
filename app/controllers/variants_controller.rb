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
    puts "UPDATE"
    @ids, @skus, @failures = Variant.update_skus(management, params.except(:action,:controller,:format))
  end

  def create
    shopify_variant_ids = params[:shopify_variant_ids]
    failures = Variant.batch_create_variants(current_shop, shopify_variant_ids)
    if failures == 0
      redirect_to variants_path, notice: pluralize(shopify_variant_ids.length, 'Variant') + "now managed by shipwire."
    else
      redirect_to variants_path, alert: pluralize(failures, 'Variant') + "did not manage to save, please check the sku."
    end
  end

  def destroy
    shopify_variant_ids = params[:shopify_variant_ids]
    Variant.batch_destroy_variants(current_shop, shopify_variant_ids)
    redirect_to variants_path, notice: pluralize(shopify_variant_ids.length, 'Variant') + "now managed by shopify."
  end

end