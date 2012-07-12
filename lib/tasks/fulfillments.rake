namespace :fulfillments do
  desc "Update fulfillment tracking information"
  task :track => :environment do
    Resque.enqueue(FulfillmentsTracker) 
  end
end
