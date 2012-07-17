class Order < ActiveRecord::Base

  PER_PAGE = 10

  attr_protected

  has_many :line_items#, :dependent => :destroy
  has_one :shipping_address#, :dependent => :destroy
  belongs_to :setting

  validate :order_from_shop?

  def self.get_paginated_orders(current_setting, page)
    return Order.find(:all, :params => {:limit => PER_PAGE, :page => page}, :conditions => ["setting_id = ?", current_setting.id])
  end

  private

  def order_from_shop?
    return true
  end
end