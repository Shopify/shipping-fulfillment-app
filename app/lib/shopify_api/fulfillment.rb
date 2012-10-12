module ShopifyAPI
  class Fulfillment < Base
    def complete; load_attributes_from_response(post(:complete, {}, only_id)); end
  end
end