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

  test "show: presents form for login if no current shop" do
    session.clear
    get :show
    assert_redirected_to controller: 'login', action: 'index'
  end

  test "create: if save then flash notice" do
    params = {shop: {login: 'david', password: 'pass', automatic_fulfillment: true}}
    session = {shopify: stub(token: 'token'), shop: 'domain'}
    post :create, params, session
    assert_redirected_to controller:'shops', action: 'show'
  end

  test "create: if not save flash alert" do
    params = {shop: {automatic_fulfillment: true}}
    session = {shopify: stub(token: 'token'), shop: 'domain'}
    post :create, params, session
    assert_redirected_to controller: 'shops', action: 'new'
  end

  test "update: if save then flash notice" do
    params = {login: 'david', password: 'pass', automatic_fulfillment: true}
    session = {shop: @shop.domain}
    put :update, params
    assert_redirected_to controller:'shops', action: 'show'
  end

  test "update: if not save flash alert" do
    params = {shop: {login: nil}}
    put :update, params
    assert_redirected_to controller:'shops', action: 'edit'
  end
end
