namespace :variants do
  desc "Synchronizes the inventory quantities in the shipwire application with shipwire"
  task :synchronize => :environment do
    VariantSynchronizer.perform
  end
end
