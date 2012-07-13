class Fulfillment < ActiveRecord::Base
  attr_accessible :status, :address, :order_id, :message, :email, :shipping_method, :shopify_order_id, :setting, :line_items, :tracker

  belongs_to :setting
  has_many :line_items, :dependent => :destroy
  has_one :tracker, :dependent => :destroy

  serialize :address
  validate :legal_shipping_method
  validates_presence_of :shopify_order_id
  validates_associated :tracker, :line_items

  ## status: pending, cancelled, success, failure
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
    if params.has_key? :shopify_order_ids
      self.fulfill_orders?(current_setting, params)
    else
      self.fulfill_line_items?(current_setting, params)
    end
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


  private

  def self.fulfill_line_items?(current_setting, params)
    order = ShopifyAPI::Order.find(params[:shopify_order_id])
    self.create_fulfillment(current_setting, order, params[:shipping_method], params[:warehouse], params[:line_item_ids])
  end

  def self.fulfill_orders?(current_setting, params)
    params[:shopify_order_ids].each do |shopify_order_id|
      order = ShopifyAPI::Order.find(shopify_order_id)    
      return false unless self.create_fulfillment(current_setting, order, params[:shipping_method], params[:warehouse])
    end
    true
  end

  def self.create_fulfillment(current_setting, order, shipping_method, warehouse, line_item_ids = 'all')

    shipwire_order_id = self.make_shipwire_order_id(order.id)
    tracker = Tracker.new({shipwire_order_id: shipwire_order_id})
    line_items = self.build_line_items(order, line_item_ids)

    options = {
        warehouse: warehouse,
        email: order.email, 
        shipping_method: shipping_method
      }

    fulfillment = Fulfillment.new(
      {
        status: 'pending',
        address: order.shipping_address.attributes, 
        shopify_order_id: order.id, 
        email: order.email, 
        shipping_method: shipping_method,
        setting: current_setting,
        line_items: line_items,
        tracker: tracker
      })

    if fulfillment.save
      Resque.enqueue(
        Fulfiller, 
        fulfillment.id, 
        shipwire_order_id, 
        order.shipping_address.attributes, 
        line_items,     
        options
      )

      fulfillment.create_mirror_fulfillment_on_shopify
      true
    else
      false
    end
  end

  def self.build_line_items(order, line_item_ids)
    if line_item_ids == 'all'
      line_items = order.line_items.map(&:attributes)
    else
      line_items = order.line_items.select{|item| line_item_ids.include? item.id}
      line_items = line_items.map(&:attributes)
    end
    line_items.each do |item|
      item[:line_item_id] = item[:id]
      item.delete(:id)
    end
    line_items.map{|item| LineItem.new(item)}
  end

  #eventually make this sequenced
  def self.make_shipwire_order_id(shopify_order_id)
    number = SecureRandom.hex(16) 
    "#{shopify_order_id}.#{number}"
  end

  def update_fulfillment_status_with_shopify
    fulfillment = ShopifyAPI::Fulfillment.find(shopify_fulfillment_id)
    case status 
    when :success
      fulfillment.status = 'success'
    when :cancelled
      fulfillment.status = 'cancelled'
    when :record_failure
      fulfillment.status = 'record_failure'
    end
    fulfillment.save
  end

  def legal_shipping_method
    errors.add(:shipping_method, 'Must be one of the shipwire shipping methods.') unless ['1D', '2D', 'GD', 'FT', 'INTL'].include?(shipping_method)
  end
end