require 'test_helper'

class ShopsControllerTest < ActionController::TestCase

  def setup
    super
    session[:shopify] = stub_api_session
    stub_controller_filters(ShopsController)
  end

  test "show: presents form with current shop info filled in" do
    get :show
    assert_select 'li'
  end

  test "show: presents form for new shop if no current shop" do
    ShopsController.any_instance.stubs(:current_shop).returns(nil)
    get :show
    assert_select '.field'
  end

  test "create: if save then flash notice" do
    Resque.expects(:enqueue)
    params = {shop: {login: 'david', password: 'pass', automatic_fulfillment: true}}
    session = {shopify: stub(token: 'token'), shop: 'domain'}
    get :create, params, session
    assert_redirected_to shop_path, notice: 'Your settings have been saved.'
  end

  test "create: if not save flash alert" do
    params = {shop: {automatic_fulfillment: true}}
    session = {shopify: stub(token: 'token'), shop: 'domain'}
    get :create, params, session
    assert_redirected_to shop_path, alert: 'Invalid settings, was not able to save.'
  end

  test "update: if save then flash notice" do
    params = {login: 'david', password: 'pass', automatic_fulfillment: true}
    session = {shop: @shop.domain}
    put :update, params
    assert_redirected_to shop_path, notice: 'Your settings have been updated.'
  end

  test "update: if not save flash alert" do
    params = {shop: {login: nil}}
    get :update, params
    assert_redirected_to shop_path, alert: 'Could not successfully update!'
  end
end
