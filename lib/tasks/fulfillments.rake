namespace :fulfillments do
  desc "Update fulfillment tracking information"
  task :track => :environment do
    FulfillmentTracker.perform
  end
end
