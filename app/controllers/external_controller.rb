class ExternalController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_before_filter :shop_exists
  skip_around_filter :shopify_session

  rescue_from Exception {|exception| head :ok } unless Rails.env == 'test'

  def shipping_rates
    
  end
end
