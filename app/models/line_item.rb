class LineItem < ActiveRecord::Base

  PER_PAGE = 10

  attr_accessible :fulfillment_service, :fulfillment_status, :grams, :line_item_id, :price, :product_id, :quantity, :requires_shipping, :sku, :title, :variant_id, :variant_title, :vendor, :name, :variant_inventory_management

  belongs_to :order

  validates_presence_of :product_id, :variant_id, :line_item_id

  def self.get_paginated_line_items(current_setting, order_id, page)
    return LineItem.find(:all, :params => {:limit => PER_PAGE, :page => page, :conditions => ["order_id = ? AND setting_id =?", order_id, current_setting.id]})
  end

end