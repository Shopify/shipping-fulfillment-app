require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  def setup 
    session[:shopify] = ShopifyAPI::Session.new("example.myshopify.com")
    ShopifyAPI::Base.expects(:activate_session => true)

    @order1 = stub(fulfillment_status: nil,
      id: 35,
      name: "#1029",
      created_at: "2012-06-28T10:52:12-04:00",
      financial_status: "pending",
      total_price: "260.00",
      currency: "CAD",
      billing_address: stub(name: "David Thomas"),
      line_items: [stub(
        id: 1,
        name: "Sticker Pack",
        sku: "GN-600-46",
        fulfillment_service: "shopify",
        fulfillment_status: "fulfilled",
        requires_shipping: true,
        price: "10.00"
        ), 
      stub(
        id: 2,
        name: "Basketball",
        sku: "GN-600-46",
        fulfillment_service: "manual",
        fulfillment_status: nil,
        requires_shipping: false,
        price: "40.00"
        ), 
      stub(
        id: 3,
        name: "Bicycle",
        sku: "GN-600-46",
        fulfillment_service: "shipwire",
        fulfillment_status: nil,
        requires_shipping: true,
        price: "96.00"
        )]
    )

    @order2 = stub(fulfillment_status: 'fulfilled',
      id: 36,
      name: "#1030",
      created_at: "2012-06-28T10:52:12-04:00",
      financial_status: "paid",
      total_price: "260.00",
      currency: "CAD",
      billing_address: stub(name: "David Thomas")
    )
  end 

  test "index: fulfill checkbox appears if automatic fulfillment set to false" do 
    Setting.stubs(:where).returns([stub(:automatic_fulfillment => false)])
    ShopifyAPI::Order.stubs(:all).returns([@order1, @order2])
    OrdersController.any_instance.stubs(:get_paginated_orders).returns([@order1, @order2])    

    get :index
    assert_template :index
    assert_tag :tag => 'input',
          :attributes => {:class => 'selector'}
  end

  test "index: no fulfill checkbox appears if automatic fulfillment set to true" do
    Setting.stubs(:where).returns([stub(:automatic_fulfillment => true)])
    ShopifyAPI::Order.stubs(:all).returns([@order1, @order2])
    OrdersController.any_instance.stubs(:get_paginated_orders).returns([@order1, @order2])    

    status = stub(:automatic_fulfillment => true)
    Setting.stubs(:where).returns([status])

    get :index
    assert_template :index
    assert_no_tag :tag => 'input',
          :attributes => {:class => 'selector'}
  end

  test "index: get_paginated_orders is called and makes call to ShopifyAPI" do 
    Setting.stubs(:where).returns([stub(:automatic_fulfillment => false)])
    ShopifyAPI::Order.stubs(:all).returns([])
    ShopifyAPI::Order.expects(:find).with(:all, :params => {:limit => 10, :page => 1}).returns([@order1, @order2])

    get :index
  end

  test "index: has message and no form when no shop has no orders" do 
    Setting.stubs(:where).returns([stub(:automatic_fulfillment => false)])
    ShopifyAPI::Order.stubs(:all).returns([])
    OrdersController.any_instance.stubs(:get_paginated_orders).returns([])

    get :index

    assert_no_tag 'form'
    assert_select 'p'
    assert_select 'table', false
  end

  test "show renders as expected" do
    Setting.stubs(:where).returns([stub(:automatic_fulfillment => false)])
    ShopifyAPI::Order.expects(:find).with(@order1.id.to_s).returns(@order1)
    OrdersController.any_instance.expects(:get_paginated_line_items).with(1).returns(@order1.line_items)

    get :show, :id => @order1.id
    assert_template :show
  end

  test "show: get_paginated_line_items paginates correctly" do
    Setting.stubs(:where).returns([stub(:automatic_fulfillment => false)])
    ShopifyAPI::Order.expects(:find).with(@order1.id.to_s).returns(@order1)
    OrdersController.any_instance.expects(:get_paginated_line_items).with(1).returns(@order1.line_items*4)
    Array.any_instance.expects(:count).returns(12)

    get :show, :id => @order1.id
    assert_select ".paginate > li", 2
  end

  test "show: get_paginated_line_items redirects to page 1 if page out of bounds" do
    Setting.stubs(:where).returns([stub(:automatic_fulfillment => false)])
    ShopifyAPI::Order.expects(:find).with(@order1.id.to_s).returns(@order1)
    OrdersController.any_instance.expects(:get_paginated_line_items).with(2).returns(@order1.line_items)

    get :show, :id => @order1.id, :page => 2
    assert_select ".paginate > li", 1
  end
end