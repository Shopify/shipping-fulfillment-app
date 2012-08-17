require 'test_helper'

# FakeWeb.allow_net_connect = true

class VariantTest < ActiveSupport::TestCase

  def setup
    super
  end

  test "#last_fulfilled_order_address gets the address of last fulfilled ordered with given variant" do
    stub_variant_callbacks

    order = create_order
    item = order.line_items.first
    item.update_attribute(:fulfillment_status, 'fulfilled')
    variant = create(:variant, shopify_variant_id: item.variant_id, shop: item.shop)

    expected_address = order.address
    assert_equal expected_address, variant.last_fulfilled_order_address
  end

  test "Valid variant saves" do
    stub_variant_callbacks
    assert create(:variant)
  end

  test "confirm_sku checks sku" do
    Variant.any_instance.stubs(:update_shopify)
    variant = build(:variant, shop: @shop)
    ActiveMerchant::Fulfillment::ShipwireService.any_instance.expects(:fetch_stock_levels).with({sku: variant.sku}).returns(stub({stock_levels: {variant.sku => 10}, success: true}))

    assert variant.save
    assert_equal 10, variant.quantity
  end

  test "update_shopify makes update_attributes call to shopify" do
    Variant.any_instance.stubs(:confirm_sku)
    variant = build(:variant)
    shopify_variant = MockShopifyVariant.new
    ShopifyAPI::Variant.expects(:find).returns(shopify_variant)
    shopify_variant.expects(:save!)

    assert variant.save
    assert_equal variant.quantity, shopify_variant.inventory_quantity
    assert_equal 'shipwire', shopify_variant.inventory_management
  end

  test "#self.batch_create_variants successfully creates variants" do
    basketball = stub(sku: '1', title: 'basketball')
    baseball = stub(sku: '2', title: 'baseball')
    football = stub(sku: '3', title: 'football')

    ShopifyAPI::Variant.expects(:find).with(1).returns(basketball)
    ShopifyAPI::Variant.expects(:find).with(2).returns(baseball)
    ShopifyAPI::Variant.expects(:find).with(3).returns(football)

    stub_variant_callbacks
    assert_difference "Variant.count", 3 do
      Variant.batch_create_variants(@shop, [1,2,3])
    end
  end

  test "#self.batch_create_variants counts number of failed creation attempts" do
    basketball = stub(sku: '1', title: 'basketball')
    baseball = stub(sku: '2', title: 'baseball')
    football = stub(sku: '3', title: 'football')

    unsaved = stub(save: false)
    saved = stub(save: true)

    ShopifyAPI::Variant.expects(:find).with(1).returns(basketball)
    ShopifyAPI::Variant.expects(:find).with(2).returns(baseball)
    ShopifyAPI::Variant.expects(:find).with(3).returns(football)

    Variant.stubs(:new).with(shopify_variant_id: 1, sku: '1', title: 'basketball').returns(unsaved)
    Variant.stubs(:new).with(shopify_variant_id: 2, sku: '2', title: 'baseball').returns(unsaved)
    Variant.stubs(:new).with(shopify_variant_id: 3, sku: '3', title: 'football').returns(saved)

    stub_variant_callbacks
    assert_equal 2, Variant.batch_create_variants(@shop, [1,2,3])
  end

  test "#self.managed? checks that management matches up with the variants service" do
    true_tests = {
      'shipwire' => 'shipwire',
      'shopify' => 'shopify',
      'other' => 'amazon_ws',
      'other' => 'webgistics',
      'none' => '',
      'none' => nil
    }

    true_tests.each do |management, service|
      assert Variant.managed?(management, service)
    end

    false_tests = {
      'shipwire' => 'shopify',
      'shopify' => 'shipwire',
      'other' => '',
      'shipwire' => 'webgistics',
      'none' => 'shopify'
    }

    false_tests.each do |management, service|
      assert !Variant.managed?(management, service)
    end
  end

  test "self.paginate paginates correctly" do
    variants = (0..100).to_a

    assert_equal (0..29).to_a, Variant.paginate(variants, 0)
    assert_equal (30..59).to_a, Variant.paginate(variants, 1)
    assert_equal (60..89).to_a, Variant.paginate(variants, 2)
    assert_equal (90..100).to_a, Variant.paginate(variants, 3)
  end

  test "self.paginate paginates returns empty array if passed an empty array" do
    assert_equal [], Variant.paginate([], 0)
  end

  test "self.batch_create_variants creates new variants" do
    mock_shopify_variants
    stub_variant_callbacks

    assert_difference "Variant.count", 2 do
      assert_equal 0, Variant.batch_create_variants(@shop, [1,2])
    end
  end

  test "self.batch_create_variants counts failed saves" do
    mock_shopify_variants

    true_save = stub(save: true)
    false_save = stub(save: false)

    Variant.expects(:new).with(shopify_variant_id: 1, sku: "GK5-90L", title: "Chive T-shirt").returns(false_save)
    Variant.expects(:new).with(shopify_variant_id: 2, sku: "GK5-90L", title: "Chive T-shirt").returns(true_save)
    stub_variant_callbacks

    assert_equal 1, Variant.batch_create_variants(@shop, [1,2])
  end

  test "self.filter_and_paginate_variants filters and paginates variants" do
    product1 = MockShopifyProduct.new('shipwire', 'bicycle')
    product2 = MockShopifyProduct.new('shipwire', 'painting')
    product3 = MockShopifyProduct.new('shopify', 'basketball')

    products = [product1, product2, product3]

    expected_variants = product1.variants + product2.variants
    ShopifyAPI::Product.expects(:all).returns(products)

    assert_equal [expected_variants, 1], Variant.filter_and_paginate_variants('shipwire',0)
  end

  test "self.find_and_set_sku finds a shipwire managed variant and updates its sku" do
    stub_variant_callbacks
    variant = create(:variant, id: 10)

    Variant.find_and_set_sku('shipwire', 10, 'YTK-974')
    assert_equal 'YTK-974', variant.reload.sku
  end

  test "self.find_and_set_sku finds a shopify variant and updates its sku" do
    stub_variant_callbacks
    variant = MockShopifyVariant.new
    ShopifyAPI::Variant.expects(:find).returns(variant)
    variant.stubs(:save)

    Variant.find_and_set_sku('shopify', 10, 'YTK-974')
    assert_equal 'YTK-974', variant.sku
  end

  test "#self.update_skus provides the ids and skus of all the updated variants" do
    variant1 = MockShopifyVariant.new('shipwire',1,'JIF-043')
    variant2 = MockShopifyVariant.new('shipwire',2,'YWZ-922')
    params = {variant1.id => variant1.sku, variant2.id => variant2.sku}

    Variant.stubs(:find_and_set_sku).returns(true)

    ids = [1,2]
    skus = ['JIF-043','YWZ-922']
    failures = []
    assert_equal [ids, skus, failures], Variant.update_skus('shipwire', params)
  end

  test "#self.update_skus provides the variant ids for all the updates that failed" do
    variant1 = MockShopifyVariant.new('shipwire',1,'JIF-043')
    variant2 = MockShopifyVariant.new('shipwire',2,'YWZ-922')
    variant3 = MockShopifyVariant.new('shipwire',3,'FCT-388')
    params = {
      variant1.id => variant1.sku,
      variant2.id => variant2.sku,
      variant3.id => variant3.sku
    }

    Variant.expects(:find_and_set_sku).with('shipwire',1,'JIF-043').returns(true)
    Variant.expects(:find_and_set_sku).with('shipwire',2,'YWZ-922').returns(false)
    Variant.expects(:find_and_set_sku).with('shipwire',3,'FCT-388').returns(false)

    ids = [1]
    skus = ['JIF-043']
    failures = [2,3]
    assert_equal [ids, skus, failures], Variant.update_skus('shipwire', params)
  end

  test "#self.batch_destroy_variants destroys all the variants corresponding to the shopify order ids" do
    stub_variant_callbacks
    create(:variant, shop: @shop, shopify_variant_id: 1)
    create(:variant, shop: @shop, shopify_variant_id: 2)

    mock_shopify_variants

    assert_difference "Variant.count", -2 do
      Variant.batch_destroy_variants(@shop, [1,2])
    end
  end

  def mock_shopify_variants
    ShopifyAPI::Variant.expects(:find).with(1).returns(MockShopifyVariant.new)
    ShopifyAPI::Variant.expects(:find).with(2).returns(MockShopifyVariant.new)
  end

  class MockShopifyVariant
    attr_accessor :inventory_management, :inventory_quantity, :sku, :title, :product_title, :id

    def initialize(inventory_management='shopify', id=1, sku='GK5-90L')
      @id = id
      @sku = sku
      @inventory_management = inventory_management
      @inventory_quantity = 10
      @title = "Chive T-shirt"
      @product_title = nil
    end

    def save
      true
    end
  end

  class MockShopifyProduct
    attr_accessor :variants, :title

    def initialize(management, title)
      @variants = (0..10).to_a.map {MockShopifyVariant.new(management)}
      @title = title
    end
  end
end

