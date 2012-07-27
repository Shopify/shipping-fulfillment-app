class Fulfillment < ActiveRecord::Base
  ## TODO: attr_accessible
  attr_protected
  belongs_to :shop
  belongs_to :order
  has_many :fulfillment_line_items, :dependent => :delete_all
  has_many :line_items, :through => :fulfillment_line_items


  validates_presence_of :order_id, :line_items, :shipwire_order_id
  validate :legal_shipping_method
  validate :order_fulfillment_status


  before_validation :make_shipwire_order_id
  after_create :create_mirror_fulfillment_on_shopify, :update_fulfillment_statuses

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
    after_transition :pending => any, :do => [:update_fulfillment_status_on_shopify]
  end

  def self.fulfill(current_shop, params)
    order_ids = params[:order_ids]
    shipping_method = params[:shipping_method]
    warehouse = params[:warehouse] || '00'
    line_item_ids = params[:line_item_ids] || []
    self.fulfill_orders(current_shop, order_ids, shipping_method, warehouse, line_item_ids)
  end


  private

  def self.fulfill_orders(current_shop, order_ids, shipping_method, warehouse, line_item_ids)
    valid_order_ids = order_ids.select { |id| current_shop.orders.map(&:id).include? id }
    valid_order_ids.each do |id|
      order = Order.find(id)
      return false unless self.create_fulfillment(current_shop, order, shipping_method, warehouse, line_item_ids)
    end
    true
  end

  def self.create_fulfillment(current_shop, order, shipping_method, warehouse, line_item_ids)

    fulfillment = current_shop.fulfillments.new(
      {
        warehouse: warehouse,
        order_id: order.id,
        email: order.email,
        shipping_method: shipping_method,
        status: 'pending',
        line_items: order.filter_fulfillable_items(line_item_ids)
      })

    if fulfillment.save
      Resque.enqueue(FulfillmentJob, fulfillment.id)
      return true
    end
    false
  end

  def create_mirror_fulfillment_on_shopify
    fulfillment = ShopifyAPI::Fulfillment.create(
      order_id: self.order.shopify_order_id,
      test: false,
      shipping_method: shipping_method,
      line_items: line_items.map(&:line_item_id)
    )

    self.update_attribute(:shopify_fulfillment_id,fulfillment.id)
  end

  def update_fulfillment_status_on_shopify
    fulfillment = ShopifyAPI::Fulfillment.find(shopify_fulfillment_id)
    fulfillment.update_attribute(:status,"#{status}") if [:success, :cancelled, :record_failure].include?(status)
  end

  def order_fulfillment_status
    errors.add(:order, 'Fulfillment status cannot be fulfilled or cancelled.') if (order.fulfillment_status == 'fulfilled') || (order.fulfillment_status =='cancelled')
    rescue NoMethodError
  end

  def legal_shipping_method
    errors.add(:shipping_method, 'Must be one of the shipwire shipping methods.') unless ['1D', '2D', 'GD', 'FT', 'INTL'].include?(shipping_method)
  end

  def make_shipwire_order_id
    number = SecureRandom.hex(16)
    self.shipwire_order_id ||= "#{self.order.id}.#{number}"
  end

  def update_fulfillment_statuses
    line_items.each { |item| item.update_attribute(:fulfillment_status, 'fulfilled')}
    order.update_attribute(:fulfillment_status,'fulfilled') if Order.find(order.id).line_items.all?{ |item| item.fulfillment_status == 'fulfilled'}
  end
end