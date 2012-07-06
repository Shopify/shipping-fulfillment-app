class Fulfillment < ActiveRecord::Base
  attr_protected 

  belongs_to :setting

  serialize :line_items
  serialize :address
  validate :legal_shipping_method
  validates_presence_of :line_items, :address, :order_id


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

  ##eventually need to deal with email options and shipping_service options
  def self.fulfill_line_items?(current_setting, order_id, line_item_ids, shipping_method, tracking_number)
    order = ShopifyAPI::Order.find(order_id)
    options = {:order_date => order.created_at, :comment => "Thank you for your purchase", :email => order.email, :tracking_number => nil, :shipping_method => shipping_method}
    address = order.shipping_address.attributes
    line_items = order.line_items.select{|item| line_item_ids.include? item.id}
    fulfillment = Fulfillment.new(
    {
      setting: current_setting,
      status: 'pending',
      line_items: line_items, 
      address: address, 
      order_id: order.id, 
      message: options[:comment], 
      email: order.email, 
      shipping_method: shipping_method, 
      tracking_number: tracking_number
    })
    if fulfillment.save
      Resque.enqueue(Fulfiller, fulfillment.id, order.id, address, line_items, options)
      true
    else
      false
    end
  end



  def self.fulfill_orders?(current_setting, order_ids, shipping_method, tracking_number)
    order_ids.each do |order_id|
      order = ShopifyAPI::Order.find(order_id)
      options = {:order_date => order.created_at, :comment => "Thank you for your purchase", :email => order.email, :tracking_number => nil, :shipping_method => shipping_method}

      fulfillment = Fulfillment.new(
      {
        setting: current_setting,
        status: 'pending',
        line_items: order.line_items, 
        address: address, 
        order_id: order.id, 
        message: options[:comment], 
        email: order.email, 
        shipping_method: shipping_method, 
        tracking_number: tracking_number
      })
      if fulfillment.save
        Resque.enqueue(Fulfiller, fulfillment.id, order.id, address, line_items, options)
      else
        return false
      end
    end
  end

  private

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