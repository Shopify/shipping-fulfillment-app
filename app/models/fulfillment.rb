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


  def self.fulfill(shop, order_ids, shipping_method, tracking_number, items = nil)
    response = true
    puts "orders: #{order_ids}, class: #{order_ids.class}"
    order_ids.each do |id|
      order = ShopifyAPI::Order.find(id)
      address =  order.shipping_address.attributes
      options = {:order_date => order.created_at, :comment => "Thank you for your purchase", :email => order.email, :tracking_number => nil, :shipping_method => shipping_method}
      setting_id = current_setting.id

      if items != nil
        line_items = order.line_items.select{|li| items.include? li.id}
      else
        line_items = order.line_items.map{|li| li.attributes}
      end
      
      fulfillment = Fulfillment.new({setting_id: setting_id,
        status: 'pending',
        line_items: line_items, 
        address: address, 
        order_id: order.id, 
        message: options[:comment], 
        email: order.email, 
        shipping_method: shipping_method, 
        tracking_number: tracking_number})

      saved = fulfillment.save
      if !saved
        response = false
      else
        Resque.enqueue(Fulfiller, fulfillment.id, order.id, address, line_items, options)
      end
    end
    return response
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