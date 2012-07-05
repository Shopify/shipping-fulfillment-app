namespace :variants do
  task :synchronize => :environment do
    VariantSynchronizer.perform
  end
end
