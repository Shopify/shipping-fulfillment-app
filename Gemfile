source 'https://rubygems.org'

gem 'rails', '3.2.6'

gem 'thin'

gem 'simple_form'

gem "sqlite3", "~> 1.3.6"
gem 'active_fulfillment', "1.0.3",  :git => 'git://github.com/Shopify/active_fulfillment.git'
gem "active_shipping",    "0.9.14", :git => 'git://github.com/Shopify/active_shipping.git'
gem 'less-rails-bootstrap'
gem 'jquery-rails'
gem "state_machine", "~> 1.1.2"
gem 'shopify_app'
gem 'shopify_api', "3.0.1"
gem 'resque', :require => 'resque/server'
gem 'redis', '~> 2.2.0', :require => ['redis/connection/hiredis', 'redis'], :git => 'git://github.com/ssoroka/redis-rb.git', :branch => 'srem_patch', :ref => '949568e'
gem 'hiredis','~> 0.4.5' # Faster redis
gem "will_paginate", "~> 3.0.3"
gem 'bootstrap-will_paginate'

# To use debugger
gem 'debugger'


group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platforms => :ruby
end


group :test do
  gem 'fakeweb', '~> 1.3.0'
  gem 'mocha', '~> 0.11.4', :require => false
  gem 'capybara'
  gem 'shoulda', '~> 3.0.1'
  gem "factory_girl_rails", "~> 3.0"
end