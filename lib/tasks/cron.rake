namespace :cron do
  task :daily => ["variants:synchronize"]
end
