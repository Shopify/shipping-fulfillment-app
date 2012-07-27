require 'test_helper'

class VariantsControllerTest < ActionController::TestCase
  def setup
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)
    @shop = create(:shop)
    session[:shopify] = ShopifyAPI::Session.new("http://localhost:3000/admin","123")
    ShopifyAPI::Base.stubs(:activate_session => true)
    shopify_variant1 = stub({id: 1, title: 'Red Razor', sku: 'GA8-94K', inventory_quantity: 20, inventory_management: 'shipwire'})
    shopify_variant2 = stub({id: 1, title: 'Blue Raindrop', sku: 'LL5-2EF', inventory_quantity: 10, inventory_management: 'shopify'})
    product = stub({title: 'Bicycle', variants: [shopify_variant1, shopify_variant2]})
    ShopifyAPI::Product.stubs(:all).returns([product])
    ShopifyAPI::Variant.stubs(:find).returns(shopify_variant1)
    VariantsController.any_instance.stubs(:shop_exists)
    VariantsController.any_instance.stubs(:current_shop).returns(@shop)
    Variant.any_instance.stubs(:fetch_quantity)
  end

  test "index: renders page correctly" do
    get :index
    assert_template :index
  end

  test "show: renders page correctly" do
    get :show, {id: 1, product_title: 'Bicycle'}
    assert_template :show
  end

  test "create: redirects with alert if bad sku" do
    Variant.stubs(:good_sku?).with(@shop,'AAA-999').returns(false)
    get :create, {sku: 'AAA-999'}
    assert_redirected_to variants_path, alert: "The sku is not recognized by Shipwire. Please enter a valid sku."
  end

  test "create: redirects with notice if good sku" do
    Variant.stubs(:good_sku?).with(@shop,'AAA-999').returns(true)
    get :create, {shopify_variant_id: 1, sku: 'AAA-999'}
    assert_redirected_to variants_path, notice: "The variants inventory will now be managed by shipwire."
  end

  test "create: redirects with notice if variant does not save" do
    Variant.stubs(:good_sku?).with(@shop, 'AAA-999').returns(true)
    Variant.stubs(:create).returns(false)
    get :create, {shopify_variant_id: 1, sku: 'AAA-999'}
    assert_redirected_to variants_path, alert: "The variant is invalid and is not managed by shipwire."
  end

  test "delete: destroys variant" do
    variant = create(:variant, shop: @shop)
    delete :destroy, {id: variant.id}
    assert_equal Variant.count, 0
  end
end
