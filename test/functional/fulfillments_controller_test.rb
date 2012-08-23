require 'test_helper'

class FulfillmentsControllerTest < ActionController::TestCase

  def setup
    super
    session[:shopify] = ShopifyAPI::Session.new("http://localhost:3000/admin","123")
    stub_api_session
    stub_fulfillment_callbacks
    stub_controller_filters(FulfillmentsController)
  end

  test "index: page renders" do
    get :index
    assert_template :index
  end

  test "show: page renders and has columns corresponding to being returned" do
    fulfillment = create(:fulfillment, :line_items => [build(:line_item)], returned: "Yes", shop: @shop)

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


