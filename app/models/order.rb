class Order < ActiveRecord::Base
  attr_protected

  has_many :line_items
  has_one :shipping_address

  validate :order_from_shop



  private

  def order_from_shop
    return true
  end
end
