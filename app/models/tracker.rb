class Tracker < ActiveRecord::Base
  attr_protected :title, :body

  belongs_to :fulfillment

  after_save update

end
