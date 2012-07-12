require 'test/unit.rb'
require 'test_helper'

class ShippingRateTest < ActiveSupport::TestCase

  test "test_ShippingRates_find_rates" do
    fake "admin/orders/18", :body => load_fixture('order18'), :method => :get,  :format => 'json', :base_url => 'http://localhost:3000/'
    destination = Destination.build_example
    rates = ShippingRates.new()
    rates.find_rates(destination, 18)
    assert true
  end

end

class Destination
  attr_reader :name, :address1, :city, :zip, :country_code, :state, :address2, :address3

  def initialize(name, address1, city, zip, country_code, state)
    @name = name
    @address1 = address1
    @city = city
    @zip = zip
    @country_code = country_code
    @state = state
    @address2 = nil
    @address3 = nil
  end

  def self.build_example
    destination = Destination.new('name','190 MacLaren Street','Ottawa','K2P 0L6','CA','Ontario')
  end
end