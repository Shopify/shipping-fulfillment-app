require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  def setup
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)
    @shop = create(:shop)
  end

  test "index: authenticates if shop it is passed the shop" do
    get :index, shop: @shop.domain
    assert_redirected_to "/auth/shopify?shop=#{@shop.domain.to_s.strip}"
  end

  test "finalize: redirects when auth fails" do
    ActionController::TestRequest.any_instance.stubs(:env).returns('omniauth.auth' => false)

    get :finalize
    assert_redirected_to action: 'index', alert: 'Could not log in to Shopify store.'
  end

  test "finalize: redirects when auth passes" do
    ActionController::TestRequest.any_instance.stubs(:env).returns('omniauth.auth' => {'credentials' => {'token' => nil}})
    ShopifyAPI::Session.stubs(:new).returns(nil)

    get :finalize, shop: @shop
    assert_redirected_to controller: 'shops', action: 'show', notice: 'Logged in'
  end

  test "logout: clears api session" do
    get :logout, nil, shopify: 1, shop: @shop.domain
    assert_redirected_to action: 'index', notice: 'Successfully logged out.'
  end

end