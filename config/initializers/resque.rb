require 'resque/server'
rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env  = ENV['RAILS_ENV'] || 'development'

Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }

if Rails.env.production?
  uri = URI.parse ENV['REDISTOGO_URL']
  Resque.redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)

  Resque::Server.use Rack::Auth::Basic do |username, password|
    username == ENV['RESQUE_USERNAME']
    password == ENV['RESQUE_PASSWORD']
  end
else
  resque_config = YAML.load_file(rails_root + '/config/resque.yml')
  Resque.redis = resque_config[rails_env]
end