namespace :fulfillments do
  desc "Update fulfillment tracking information"
  task :track => :environment do
    FulfillmentsTracker.perform
  end
end
