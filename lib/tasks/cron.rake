namespace :cron do
  desc "Runs all the periodic tasks."
  task :daily => ["variants:synchronize"]
end
