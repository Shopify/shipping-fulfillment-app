class Tracker < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :fulfillment

  # def convert_shipwire_time
  #   # use DateTime.parse
  #   /(?<year>\d\d\d\d)\-(?<month>\d\d)\-(?<day>\d\d)\ (?<hour>\d\d)\:(?<minute>\d\d)\:(?<second>\d\d)/.match("2011-03-22 00:00:00")
  # end
end
