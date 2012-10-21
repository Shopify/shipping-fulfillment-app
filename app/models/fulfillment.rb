class Fulfillment < ActiveRecord::Base

  include FlagForAfterCommit

  SHIPPING_CODES = %w(1D 2D GD FT INTL)

  attr_accessible :shopify_fulfillment_id, :email, :shipping_method, :warehouse, :tracking_carrier, :tracking_link, :tracking_number, :ship_date, :expected_delivery_date, :return_date, :return_condition, :shipper_name, :total, :returned, :shipped, :line_items, :order_id, :status

  belongs_to :shop
  has_many :fulfillment_line_items, :dependent => :delete_all
  has_many :line_items, :through => :fulfillment_line_items


  validates_presence_of :line_items, :shipwire_order_id
  validate :legal_shipping_method

  before_validation :make_shipwire_order_id
  after_create :update_association_fulfillment_statuses


  state_machine :status, :initial => :pending do
    event :success do
      transition :pending => :success
    end
    event :cancel do
      transition :pending => :cancelled
    end
    event :record_failure do
      transition :pending => :failure
    end

    after_transition any => [:success, :failure, :cancelled], :do => :update_fulfillment_status_on_shopify
  end

  def geolocation?
    locations = [origin_lat, origin_long, destination_lat, destination_long]
    locations.all? {|location| location}
  end

  def total
    line_items.reduce(0.0) do |total, line_item|
      total + line_item.total.to_f
    end
  end

  def self.new_from_params(shop, params)
    fulfillment = Fulfillment.new(extract_params(params))

    params["line_items"].each do |line_item_params|
      line_item = LineItem.new_from_params(shop, line_item_params)
      fulfillment.line_items << line_item
    end
    fulfillment
  end

  private

  def update_fulfillment_status_on_shopify
    ShopifyAPI::Session.temp(shop.base_url, shop.token) {
      shopify_fulfillment = ShopifyAPI::Fulfillment.find(shopify_fulfillment_id, :params => {:order_id => order_id})
      case status
      when "success"
        shopify_fulfillment.complete
      when "cancelled"
        shopify_fulfillment.cancel
      end
    }
  end

  def update_association_fulfillment_statuses
    line_items.each { |item| item.update_attribute(:fulfillment_status, 'fulfilled') }
  end

  def legal_shipping_method
    unless SHIPPING_CODES.include?(shipping_method)
      errors.add(:shipping_method, "'#{shipping_method}' is invalid. Must be one of the shipwire shipping methods.")
    end
  end

  def make_shipwire_order_id
    number = SecureRandom.hex(4)
    self.shipwire_order_id ||= "#{self.order_id}.#{number}"
  end

  def self.extract_params(params)
    params.slice("email", "shipping_method", "tracking_number").merge({"tracking_link" => params["tracking_url"], "shopify_fulfillment_id" => params['id']})
  end
end