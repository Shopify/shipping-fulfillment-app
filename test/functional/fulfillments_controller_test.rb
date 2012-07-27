require 'test_helper'

class FulfillmentsControllerTest < ActionController::TestCase

  def setup
    session[:shopify] = ShopifyAPI::Session.new("http://localhost:3000/admin","123")
    ShopifyAPI::Base.expects(:activate_session => true)
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)
    Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
    FulfillmentsController.any_instance.stubs(:shop_exists)
    @shop = create(:shop)
    FulfillmentsController.any_instance.stubs(:current_shop).returns(@shop)
  end

  test "index: page renders" do
    get :index
    assert_template :index
  end

  test "show: page renders and has columns corresponding to being returned" do
    fulfillment = create(:fulfillment, :line_items => [build(:line_item)], returned: "YES", shop: @shop)

    get :show, {:id => fulfillment.id.to_s}
    assert_template :show
    assert_select ".sortcol", 11
    assert_select "td", 11
  end

  test "show: page renders but does not have columns corresponding to being returned" do
    fulfillment = create(:fulfillment, :line_items => [build(:line_item)], shop: @shop)

    get :show, {:id => fulfillment.id.to_s}
    assert_template :show
    assert_select ".sortcol", 8
    assert_select "tbody > td", 8
  end

  test "create: successful" do
    Fulfillment.stubs(:fulfill).returns(true)

    post :create
    assert_redirected_to fulfillments_path, notice: "Your fulfillment request has been sent."
  end

  test "create: unsuccessful" do
    Fulfillment.expects(:fulfill).returns(false)

    post :create
    assert_redirected_to fulfillments_path, alert: "There were errors with your fulfillment request that prevented it from being sent."
  end
end


