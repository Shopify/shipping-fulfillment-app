require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  def setup
    super
  end

  test "index: authenticates if it is passed the shop" do
    get :index, shop: @shop.domain
    assert_redirected_to "/auth/shopify?shop=#{@shop.domain.to_s.strip}"
  end

  test "finalize: redirects when auth fails" do
    ActionController::TestRequest.any_instance.stubs(:env).returns('omniauth.auth' => false)

    get :finalize
    assert_redirected_to action: 'index'
  end

  test "finalize: redirects when auth passes" do
    ActionController::TestRequest.any_instance.stubs(:env).returns('omniauth.auth' => {'credentials' => {'token' => nil}})
    ShopifyAPI::Session.stubs(:new).returns(nil)

    get :finalize, shop: @shop
    assert_redirected_to controller: 'shops', action: 'new'
  end

  test "logout: clears api session" do
    get :logout, nil, shopify: 1, shop: @shop.domain
    assert_redirected_to action: 'index'
  end

end