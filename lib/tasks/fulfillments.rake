namespace :fulfillments do
  desc "Update fulfillment tracking information"
  task :track => :environment do
    FulfillmentTrackingUpdateJob.perform
  end
end
