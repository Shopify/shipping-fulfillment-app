class Fulfillment < ActiveRecord::Base

  SHIPPING_CODES = %w{1D 2D GD FT INTL}

  attr_accessible :email, :shipping_method, :warehouse, :tracking_carrier, :tracking_link, :tracking_number, :ship_date, :expected_delivery_date, :return_date, :return_condition, :shipper_name, :total, :returned, :shipped, :line_items, :order_id, :status

  belongs_to :shop
  belongs_to :order
  has_many :fulfillment_line_items, :dependent => :delete_all
  has_many :line_items, :through => :fulfillment_line_items


  validates_presence_of :order_id, :line_items, :shipwire_order_id
  validate :legal_shipping_method
  validate :order_fulfillment_status

  before_validation :make_shipwire_order_id
  after_create :create_mirror_fulfillment_on_shopify, :update_fulfillment_statuses


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
    self.fulfill_orders(current_shop, params[:order_ids], params[:shipping_method], params[:warehouse] || '00', params[:line_item_ids] || [])
  end

  def geolocation?
    locations = [origin_lat, origin_long, destination_lat, destination_long]
    locations.all? {|location| location}
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
      shipping_method: shipping_method,
      line_items: line_items.map(&:line_item_id)
    )
    self.update_attribute(:shopify_fulfillment_id, fulfillment.id)
  end

  def update_fulfillment_status_on_shopify
    fulfillment = ShopifyAPI::Fulfillment.find(shopify_fulfillment_id)
    fulfillment.update_attribute(:status,"#{status}") if [:success, :cancelled, :record_failure].include?(status)
  end

  def order_fulfillment_status
    if (order.fulfillment_status == 'fulfilled') || (order.fulfillment_status =='cancelled')
      errors.add(:order, 'Fulfillment status cannot be fulfilled or cancelled.')
    end
    rescue NoMethodError
  end

  def legal_shipping_method
    unless SHIPPING_CODES.include?(shipping_method)
      errors.add(:shipping_method, 'Must be one of the shipwire shipping methods.')
    end
  end

  def make_shipwire_order_id
    number = SecureRandom.hex(16)
    self.shipwire_order_id ||= "#{self.order.id}.#{number}"
  end

  def update_fulfillment_statuses
    line_items.each { |item| item.update_attribute(:fulfillment_status, 'fulfilled')}
    if Order.find(order.id).line_items.all?{ |item| item.fulfillment_status == 'fulfilled'}
      order.update_attribute(:fulfillment_status,'fulfilled')
    end
  end
end