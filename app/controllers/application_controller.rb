class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :shopify_session
end
