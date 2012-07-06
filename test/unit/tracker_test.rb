require 'test_helper'

class TrackerTest < ActiveSupport::TestCase
  should belong_to :fulfillment
  
  test "valid tracker saves" do
    tracker = FactoryGirl.build(:tracker)
    assert tracker.save, "Valid tracker did not save."
  end
end
