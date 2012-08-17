class Variant < ActiveRecord::Base

  Rails.env == 'development' ? PER_PAGE = 2 : PER_PAGE = 30

  attr_accessible :shopify_variant_id, :sku, :quantity, :backordered, :reserved, :shipping, :shipped, :availableDate, :shippedLastDay, :shippedLastWeek, :shippedLast4Weeks, :orderedLastDay, :orderedLastWeek, :orderedLast4Weeks, :title

  belongs_to :shop

  validates_presence_of :sku
  validates :shopify_variant_id, :presence => true, :uniqueness => true
  validate :confirm_sku

  after_create :update_shopify

  def last_fulfilled_order_address
    item = shop.line_items.order("created_at DESC")
      .where('variant_id = ? AND fulfillment_status = ?', shopify_variant_id, 'fulfilled')
      .first

    item.order.address if item.present?
  end

  def self.batch_create_variants(shop, shopify_variant_ids)
   failures = shopify_variant_ids.select do |shopify_variant_id|
      shopify_variant = ShopifyAPI::Variant.find(shopify_variant_id)
      variant = Variant.new(shopify_variant_id: shopify_variant_id, sku: shopify_variant.sku, title: shopify_variant.title)
      !variant.save
    end
    failures.length
  end

  #test
  def self.update_skus(management, params)
    ids,skus,failures = [],[],[]
    params.each do |id, sku|
      if Variant.find_and_set_sku(management, id, sku)
        ids << id
        skus << sku
      else
        failures << id
      end
    end
    [ids, skus, failures]
  end

  def self.find_and_set_sku(management, id, sku)
    if management == 'shipwire'
      variant = Variant.find(id.to_i)
      variant.update_attribute(:sku, sku)
    elsif management == 'shopify' || management == 'none'
      variant = ShopifyAPI::Variant.find(id.to_i)
      variant.sku = sku
      variant.save
    else
      nil
    end
  end

  def self.filter_and_paginate_variants(management, page)
    all_variants = ShopifyAPI::Product.all.map do |product|
      product.variants.each { |variant| variant.product_title = product.title }
      product.variants
    end

    filtered_variants = all_variants.flatten.select { |variant| Variant.managed?(management, variant.inventory_management) }
    pages = (filtered_variants.length.to_f/PER_PAGE).ceil

    variants = Variant.paginate(filtered_variants,page)
    [variants, pages]
  end

  def self.paginate(variants, page)
    return [] if variants.empty?
    first = [0, page*PER_PAGE].max
    variants[first,PER_PAGE]
  end

  def self.managed?(management, service)
    case management
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

  private

  def confirm_sku
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
    response = shipwire.fetch_stock_levels(:sku => sku)
    if response.success && response.stock_levels[sku].present?
      self.quantity = response.stock_levels[sku]
    else
      errors.add(:variant, "Must have valid sku that is recognized by Shipwire.")
    end
  end

  def update_shopify
    shopify_variant = ShopifyAPI::Variant.find(shopify_variant_id)
    shopify_variant.inventory_quantity = quantity
    shopify_variant.inventory_management = 'shipwire'
    shopify_variant.save!
  end
end