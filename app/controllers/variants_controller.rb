class VariantsController < ApplicationController

  before_filter :valid_shipwire_credentials

  Rails.env == 'development' ? PER_PAGE = 2 : PER_PAGE = 50

  def index
    @management = params[:management] || 'shipwire'
    @page = params[:page].to_i || 1
    all_variants = ShopifyAPI::Product.all.map do |product|
      product.variants.each { |variant| variant.product_title = product.title }
      product.variants
    end
    filtered_variants = all_variants.flatten.select { |variant| managed?(variant.inventory_management) }
    @pages = (filtered_variants.length.to_f/PER_PAGE).ceil
    @variants = paginate(filtered_variants)
    puts @variants.inspect
  end

  def show
    @product_title = params[:product_title]
    @variant = current_shop.variants.find_by_shopify_variant_id(params[:id])
    puts @variant.inspect
    puts "adsadsasdasdas"
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

  private

  def paginate(variants)
    return [] if variants.empty?
    first = [0, @page*PER_PAGE].max
    last = [variants.length-1, (@page+1)*PER_PAGE].min
    variants[first,last]
  end

  def managed?(service)
    case @management
    when 'shipwire'
      true if service == 'shipwire'
    when 'shopify'
      true if service == 'shopify'
    when 'other'
      true unless service.blank? || ['shipwire','shopify'].include?(service)
    when 'none'
      true if service == nil || service == ''
    end
  end

end