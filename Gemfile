source 'https://rubygems.org'

gem 'rails', '3.2.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'active_fulfillment',    '1.0.3',  :git => 'git://github.com/Shopify/active_fulfillment.git', :ref => '2200cb8'
gem "active_shipping", "~> 0.9.14"
gem 'less-rails-bootstrap'
gem 'jquery-rails'
gem 'state_machine',         '0.9.4'                             # State machine, used everywhere
gem 'shopify_app'
gem 'resque', :require => 'resque/server'
gem 'redis', '~> 2.2.0', :require => ['redis/connection/hiredis', 'redis'], :git => 'git://github.com/ssoroka/redis-rb.git', :branch => 'srem_patch', :ref => '949568e'
gem 'hiredis','~> 0.4.5' # Faster redis

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
gem 'debugger'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'therubyracer', :platforms => :ruby
end


group :test do
  gem 'fakeweb', '~> 1.3.0'
  gem 'mocha', '~> 0.11.4', :require => false
  gem 'capybara'
  gem 'shoulda', '~> 3.0.1'
  gem "factory_girl_rails", "~> 3.0"
end