class Order < ActiveRecord::Base
  attr_protected

  has_many :line_items, :dependent => :destroy
  belongs_to :shop

  accepts_nested_attributes_for :line_items

  def address
    address_hash = {}
    %w(address1 address2 city zip province country latitude longitude).each do |key|
      address_hash[key.to_sym] = self.send(key)
    end
    address_hash
  end


  def filter_fulfillable_items(line_item_ids)
    order_item_ids = self.line_items.map(&:id)
    line_item_ids = order_item_ids if line_item_ids.empty?
    valid_ids = line_item_ids.select { |id| (order_item_ids.include? id) && (LineItem.find(id).fulfillable?) }
    valid_ids.map{ |id| LineItem.find(id) }
  end

  def self.create_order(params,shop)
    options = order_options(params)
    options.merge(shipping_attributes(params))
    options[:line_items_attributes] = line_items_attributes(params, shop)
    order = shop.orders.create(options)
  end

  def self.order_options(params)
    options = params.slice(*Order.column_names)
    options[:shopify_order_id] = params[:id]
    options
  end

  def self.shipping_attributes(params)
    options = params[:shipping_address].slice(*Order.column_names)
    options.delete(:id)
    options
  end

  def self.line_items_attributes(params, shop)
    params[:line_items].map do |item|
      options = item.slice(*LineItem.column_names)
      options[:shop_id] = shop.id
      options[:line_item_id] = options.delete(:id)
      options
    end
  end

end