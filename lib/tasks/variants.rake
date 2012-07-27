namespace :variants do
  desc "Synchronizes the inventory quantities in the shipwire application with shipwire"
  task :update => :environment do
    VariantStockUpdateJob.perform
  end
end
