require 'test_helper'

class ShopsControllerTest < ActionController::TestCase

  def setup
    session[:shopify] = ShopifyAPI::Session.new("http://localhost:3000/admin","123")
    ShopifyAPI::Base.expects(:activate_session => true)
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)
    @shop = create(:shop)
    ShopsController.any_instance.stubs(:current_shop).returns(@shop)
    ShopsController.any_instance.stubs(:shop_exists)
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
    params = {shop: {domain: nil}}
    get :update, params
    assert_redirected_to shop_path, alert: 'Could not successfully update!'
  end
end
