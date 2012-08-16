require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  def setup
    super
    session[:shopify] = stub_api_session
    stub_controller_filters(OrdersController)

    @order1 = create_order
    @order2 = create_order
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

  test "index: has message and no form when no shop has no orders" do
    shop = create(:shop)
    OrdersController.any_instance.stubs(:current_shop).returns(shop)

    get :index

    assert_select 'p'
    assert_select 'table', false
    assert_select 'form', false
  end

  test "show: renders as expected" do
    get :show, {id: @order1.id}
    assert_template :show
  end

  test "all: nil page gets set to 1" do
    get :show, {id: @order1.id, page: nil}
    assert_select 'td', @order1.line_items.first.name
  end
end