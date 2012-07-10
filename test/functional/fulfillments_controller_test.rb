require 'test_helper'

class FulfillmentsControllerTest < ActionController::TestCase
  
  def setup
    FulfillmentsController.any_instance.stubs(:current_setting)
    session[:shopify] = ShopifyAPI::Session.new("http://localhost:3000/admin","123")
    ShopifyAPI::Base.stubs(:activate_session => true)
    Setting.stubs(:exists?).returns(true)
  end

  test "index: page renders" do
    get :index
    assert_template :index
  end

  test "show: page renders and has columns corresponding to being returned" do
    fulfillment = FactoryGirl.create(:fulfillment)
    fulfillment.tracker = FactoryGirl.create(:tracker)
    fulfillment.save

    get :show, {:id => fulfillment.id.to_s}
    assert_template :show
    assert_select ".sortcol", 11
    assert_select "td", 11
  end

  test "show: page renders but does not have columns corresponding to being returned" do
    fulfillment = FactoryGirl.create(:fulfillment)
    fulfillment.tracker = FactoryGirl.create(:tracker_not_returned)
    fulfillment.save

    get :show, {:id => fulfillment.id.to_s}
    assert_template :show
    assert_select ".sortcol", 8
    assert_select "tbody > td", 8
  end

  test "create: successful" do
    Fulfillment.stubs(:fulfill).returns(true)

    post :create
    assert_redirected_to action: 'index'
    assert_equal flash[:notice], "Your fulfillment request has been sent."
  end

  test "create: unsuccessful" do
    Fulfillment.expects(:fulfill).returns(false)

    post :create
    assert_redirected_to action: 'index'
    assert_equal flash[:alert], "There were errors with your fulfillment request that prevented it from being sent."
  end
end


