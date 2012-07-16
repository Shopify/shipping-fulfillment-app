class Fulfillment < ActiveRecord::Base

  attr_accessible :warehouse, :address, :shopify_order_id, :email, :shipping_method, :line_items, :status
  belongs_to :setting
  has_many :line_items, :dependent => :destroy
  has_one :tracker, :dependent => :destroy

  serialize :address

  validate :legal_shipping_method
  validate :order_fulfillment_status
  validates_presence_of :shopify_order_id
  validates_associated :tracker, :line_items


  before_create :build_tracker
  after_create :create_mirror_fulfillment_on_shopify

  # status: pending, cancelled, success, failure
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
    after_transition :pending => any, :do => [:update_fulfillment_status_with_shopify]
  end

  def self.fulfill(current_setting, params)
    shopify_order_ids = params[:shopify_order_ids]
    shipping_method = params[:shipping_method]
    warehouse = params[:warehouse]
    line_items = params[:line_item_ids] || []
    self.fulfill_orders(current_setting, shopify_order_ids, shipping_method, warehouse, line_items)
  end

  def add_line_items(line_item_ids)
    items = ShopifyAPI::Order.find(shopify_order_id).line_items
    if line_item_ids.any?
      items = items.select{|item| line_item_ids.include? item.id}
    end

    line_items = items.map do |item|
      data = item.attributes
      data[:line_item_id] = data.delete(:id)
      # TODO: use apps order object
      LineItem.new(data)
    end
  end


  private

  def self.fulfill_orders(current_setting, shopify_order_ids, shipping_method, warehouse, line_item_ids)
    shopify_order_ids.each do |shopify_order_id|
      order = ShopifyAPI::Order.find(shopify_order_id)
      return false unless self.create_fulfillment(current_setting, order, shipping_method, warehouse, line_item_ids)
    end
    true
  end

  def self.create_fulfillment(current_setting, order, shipping_method, warehouse, line_item_ids)

    fulfillment = current_setting.fulfillments.new(
      {
        warehouse: warehouse,
        address: order.shipping_address.attributes,
        shopify_order_id: order.id,
        email: order.email,
        shipping_method: shipping_method,
        status: 'pending'
      })
    fulfillment.add_line_items(line_item_ids)

    if fulfillment.save
      Resque.enqueue(Fulfiller, fulfillment.id)
      return true
    end
    puts fulfillment.errors.inspect
    false
  end

  def create_mirror_fulfillment_on_shopify
    fulfillment = ShopifyAPI::Fulfillment.new(
      order_id: shopify_order_id,
      test: false,
      shipping_method: shipping_method,
      line_items: line_items.map(&:line_item_id)
    )
    fulfillment.save
  end

  def update_shopify_fulfillment_status
    fulfillment = ShopifyAPI::Fulfillment.find(shopify_fulfillment_id)
    fulfillment.status = "#{status}" if [:success, :cancelled, :record_failure].include?(status)

    fulfillment.save
  end

  def order_fulfillment_status
    order_status = ShopifyAPI::Order.find(shopify_order_id).fulfillment_status
    return false if order_status == 'fulfilled' || order_status =='cancelled'
    true
  end

  def legal_shipping_method
    errors.add(:shipping_method, 'Must be one of the shipwire shipping methods.') unless ['1D', '2D', 'GD', 'FT', 'INTL'].include?(shipping_method)
  end

  def build_tracker
    self.tracker = Tracker.new(:fulfillment => self)
  end
end