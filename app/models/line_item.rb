class LineItem < ActiveRecord::Base
  attr_protected

  belongs_to :fulfillment

  
end
