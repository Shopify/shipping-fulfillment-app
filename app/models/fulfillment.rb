class Fulfillment < ActiveRecord::Base
  attr_protected 

  belongs_to :setting
  has_many :line_items
  has_one :tracker

  serialize :address
  validate :legal_shipping_method
  validates_presence_of :address, :order_id


  state_machine :status, :initial => 'pending' do
    event :success do
      transition :pending => :success
    end
    event :cancel do
      transition :pending => :cancelled
    end
    event :record_failure do
      transition :pending => :failure
    end

    after_transition any => any,
      :do => [:update_fulfillment_status_with_shopify]
  end

  ##eventually need to deal with warehouse options
  def self.fulfill_line_items?(current_setting, order_id, line_item_ids, shipping_method, warehouse)
    order = ShopifyAPI::Order.find(order_id)
    
    options = 
    {
      warehouse: warehouse,
      email: order.email, 
      shipping_method: shipping_method
    }
    
    fulfillment = Fulfillment.new(
    {
      setting: current_setting,
      status: 'pending',
      address: order.shipping_address.attributes, 
      order_id: order.id, 
      message: options[:comment], 
      email: order.email, 
      shipping_method: shipping_method
    })

    if fulfillment.save
      tracker = Tracker.create(fulfillment_id: fulfillment.id, shipwire_order_id: make_shipwire_order_id(order.id))
      line_items = order.line_items.select{|item| line_item_ids.include? item.id}
      line_items.each do |item|
        Line_Item.create(item.attributes)
      end
      Resque.enqueue(Fulfiller, fulfillment.id, order.id, address, line_items, options)
      true
    else
      false
    end
  end


  def self.fulfill_orders?(current_setting, order_ids, shipping_method, warehouse)
    order_ids.each do |order_id|
      order = ShopifyAPI::Order.find(order_id)
      
      options = 
      {
        warehouse: warehouse,
        email: order.email, 
        shipping_method: shipping_method
      }

      fulfillment = Fulfillment.new(
      {
        setting: current_setting,
        status: 'pending',
        address: order.shipping_address.attributes, 
        order_id: order.id, 
        message: options[:comment], 
        email: order.email, 
        shipping_method: shipping_method
      })

      if fulfillment.save
        tracker = Tracker.create(fulfillment_id: fulfillment.id, shipwire_order_id: make_shipwire_order_id(order.id))
        order.line_items.each do |item|
          LineItem.create(item.attributes)
        end
        Resque.enqueue(Fulfiller, fulfillment.id, order.id, address, line_items, options)
      else
        return false
      end
    end
  end

  private

  def make_shipwire_order_id(shopify_order_id)
    "#{shopify_order_id}.#{number}"
  end

  def update_fulfillment_status_with_shopify
    case status 
    when :success
      #make api fulfillment
    when :cancelled
      #cancell order 
    when :pending
      #use api to change status to pending
    when :record_failure
      #have to alert user somehow and change status back to unfulfilled
    end
  end

  def legal_shipping_method
    errors.add(:shipping_method, 'Must be one of the shipwire shipping methods.') unless ['1D', '2D', 'GD', 'FT', 'INTL'].include?(shipping_method)
  end
end