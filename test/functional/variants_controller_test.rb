require 'test_helper'

class VariantsControllerTest < ActionController::TestCase
  def setup
    super
    stub_variant_callbacks
    session[:shopify] = stub_api_session
    stub_controller_filters(VariantsController)
  end

  def stub_products_and_variants
    shopify_variant1 = stub({id: 1, title: 'Red Razor', sku: 'GA8-94K', inventory_quantity: 20, inventory_management: 'shipwire'})
    product = stub({title: 'Bicycle', variants: [shopify_variant1]})
    ShopifyAPI::Product.stubs(:all).returns([product])
    ShopifyAPI::Variant.stubs(:find).returns(shopify_variant1)
  end

  test "index: renders page correctly" do
    stub_products_and_variants
    get :index
    assert_template :index
  end

  test "show: renders page correctly" do
    stub_products_and_variants
    get :show, {id: 1, product_title: 'Bicycle'}
    assert_template :show
  end

  test "create: redirects with alert if bad sku" do
    Variant.any_instance.stubs(:create).returns(false)
    get :create
    assert_redirected_to variants_path, alert: "The variant is invalid and is not managed by shipwire."
  end

  test "create: redirects with notice if good sku" do
    Variant.any_instance.stubs(:create).returns(true)
    get :create
    assert_redirected_to variants_path, notice: "The variant is now managa by shipwire."
  end

  test "delete: destroys variant" do
    ShopifyAPI::Variant.stubs(:find)
    NilClass.any_instance.stubs(:update_attribute).with('inventory_management','shopify')
    variant = create(:variant, shop: @shop)
    delete :destroy, {id: variant.id}
    assert_equal 0, Variant.count
  end
end