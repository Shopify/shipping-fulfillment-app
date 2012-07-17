require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  should belong_to :setting
  should have_many :line_items
  should have_one :shipping_address

end
