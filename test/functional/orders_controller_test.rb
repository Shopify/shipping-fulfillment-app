require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  def setup
    session[:shopify] = ShopifyAPI::Session.new("http://localhost:3000/admin","123")
    ShopifyAPI::Base.expects(:activate_session => true)
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)
    OrdersController.any_instance.stubs(:shop_exists)


    @shop = create(:shop)
    OrdersController.any_instance.stubs(:current_shop).returns(@shop)

    @order1 = create(:order, shop: @shop)
    @order2 = create(:order, shop: @shop)




    # @order1 = stub(fulfillment_status: nil,
    #   id: 35,
    #   name: "#1029",
    #   created_at: "2012-06-28T10:52:12-04:00",
    #   financial_status: "pending",
    #   total_price: "260.00",
    #   currency: "CAD",
    #   billing_address: stub(name: "David Thomas"),
    #   line_items: [stub(
    #     id: 1,
    #     name: "Sticker Pack",
    #     sku: "GN-600-46",
    #     fulfillment_service: "shopify",
    #     fulfillment_status: "fulfilled",
    #     requires_shipping: true,
    #     price: "10.00"
    #     ),
    #   stub(
    #     id: 2,
    #     name: "Basketball",
    #     sku: "GN-600-46",
    #     fulfillment_service: "manual",
    #     fulfillment_status: nil,
    #     requires_shipping: false,
    #     price: "40.00"
    #     ),
    #   stub(
    #     id: 3,
    #     name: "Bicycle",
    #     sku: "GN-600-46",
    #     fulfillment_service: "shipwire",
    #     fulfillment_status: nil,
    #     requires_shipping: true,
    #     price: "96.00"
    #     )]
    # )

    # @order2 = stub(fulfillment_status: 'fulfilled',
    #   id: 36,
    #   name: "#1030",
    #   created_at: "2012-06-28T10:52:12-04:00",
    #   financial_status: "paid",
    #   total_price: "260.00",
    #   currency: "CAD",
    #   billing_address: stub(name: "David Thomas")
    # )
  end

  test "index: fulfill checkbox appears if automatic fulfillment set to false" do
    get :index
    assert_template :index
    assert_select ".selector"
  end

  test "index: no fulfill checkbox appears if automatic fulfillment set to true" do
    shop = create(:shop_true)
    OrdersController.any_instance.stubs(:current_shop).returns(shop)
    order1 = create(:order, shop: shop)

    get :index
    assert_template :index
    assert_select '.selector', false
  end

  # test "index: get_paginated_orders is called and makes call to ShopifyAPI" do
  #   ShopifyAPI::Order.stubs(:all).returns([])
  #   ShopifyAPI::Order.expects(:find).with(:all, :params => {:limit => 10, :page => 1}).returns([@order1, @order2])

  #   get :index
  # end

  # test "index: get_paginated_orders redirects to page 1 if page out of bounds" do
  #   ShopifyAPI::Order.stubs(:all).returns([])
  #   ShopifyAPI::Order.expects(:find).with(:all, :params => {:limit => 10, :page => 1}).returns([@order1, @order2])

  #   get :index, :page => 5
  #   assert_select ".paginate", 0
  # end

  test "index: has message and no form when no shop has no orders" do
    shop = create(:shop)
    OrdersController.any_instance.stubs(:current_shop).returns(shop)

    get :index

    assert_select 'p'
    assert_select 'table', false
    assert_select 'form', false
  end

  test "show renders as expected" do
    ShopifyAPI::Order.expects(:find).with(@order1.id.to_s).returns(@order1)
    OrdersController.any_instance.expects(:get_paginated_line_items).returns(@order1.line_items)

    get :show, :id => @order1.id
    assert_template :show
  end

  # test "show: get_paginated_line_items paginates correctly" do
  #   ShopifyAPI::Order.expects(:find).with(@order1.id.to_s).returns(@order1)
  #   OrdersController.any_instance.expects(:get_paginated_line_items).returns(@order1.line_items*4)
  #   Array.any_instance.expects(:count).returns(12)

  #   get :show, :id => @order1.id
  #   assert_select ".paginate > li", 2
  # end

  # test "show: get_paginated_line_items redirects to page 1 if page out of bounds" do
  #   ShopifyAPI::Order.expects(:find).with(@order1.id.to_s).returns(@order1)
  #   OrdersController.any_instance.expects(:get_paginated_line_items).returns(@order1.line_items)

  #   get :show, :id => @order1.id, :page => 5
  #   assert_select ".pagination", 0
  # end
end