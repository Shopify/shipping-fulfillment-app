require 'date'

module ActiveMerchant
  module Fulfillment
    class ShipwireService < Service

      # TODO: remove if not using
      # def fetch_tracking_updates
      #   request = buid_tracking_updates_request
      #   data = ssl_post(SERVICE_URLS[:tracking], "#{POST_VARS[:tracking]}=#{CGI.escape(request)}")

      #   response = parse_tacking_updates_response(data)
      # end

      def fetch_shop_tracking_info(shipwire_order_ids)
        request = build_tracking_request(shipwire_order_ids)
        data = ssl_post(SERVICE_URLS[:tracking], "#{POST_VARS[:tracking]}=#{CGI.escape(request)}")

        response = parse_tracking_updates_response(data)
      end

      def fetch_shop_inventory(shop)
        request = build_total_inventory_request(shop)
        data = ssl_post(SERVICE_URLS[:inventory], "#{POST_VARS[:inventory]}=#{CGI.escape(request)}")

        response = parse_total_inventory_response(data)
      end

      def build_total_inventory_request
        xml = Builder::XmlMarkup.new :indent => 2
        xml.instruct!
        xml.declare! :DOCTYPE, :InventoryStatus, :SYSTEM, SCHEMA_URLS[:inventory]
        xml.tag! 'InventoryUpdate' do
          add_credentials(xml)
        end
      end

      # TODO: remove if not using
      # def build_tracking_updates_request
      #   xml = Builder::XmlMarkup.new
      #   xml.instruct!
      #   xml.declare! :DOCTYPE, :InventoryStatus, :SYSTEM, SCHEMA_URLS[:inventory]
      #   xml.tag! 'TrackingUpdate' do
      #     add_credentials(xml)
      #     xml.tag! 'Server', test? ? 'Test' : 'Production'
      #     xml.tag! 'Bookmark', 3
      #   end
      # end

      def parse_tracking_update_response(xml)

        response ={}

        document = REXML::Document.new(xml)
        document.root.elements.each do |node|
          if node.name == "Order"
            id = node.attributes["id"]
            response[id] = {}
            get = node.attributes
            tracking = node.elements["TrackingNumber"]

            response[id]["shipped"] = get["shipped"]
            response[id]["shipper_name"] = get["shipperFullName"]
            response[id]["return_condition"] = get["returnCondition"]
            response[id]["total"] = get["total"]
            response[id]["returned"] = get["returned"]

            response[id]["ship_date"] = DateTime.parse(get["expectedDeliveryDate"]) if get["expectedDeliveryDate"]
            response[id]["expected_delivery_date"] = DateTime.parse(get["expectedDeliveryDate"]) if get["expectedDeliveryDate"]
            response[id]["return_date"] = DateTime.parse(get["returnDate"]) if get["returnDate"]

            if tracking
              response[id]["tracking_carrier"] = tracking.attributes["carrier"]
              response[id]["tracking_link"] = tracking.attributes["href"]
              response[id]["tracking_number"] = tracking.text
            end

          end
        end
        response
      end

      def parse_total_inventory_response(xml)
        response = {}
        response[:stock_levels] = {}

        document = REXML::Document.new(xml)
        document.root.elements.each do |node|
          if node.name == 'Product'
            response[:stock_levels][node.attributes['code']] = {}
            base = response[:stock_levels][node.attributes['code']]
            node.attributes.except('code','good','consuming','consumed','creating','created').each do |attribute|
              base[attribute.to_sym] = node.attributes[attribute]
            end
          end
        end

        response[:success] = test? ? response[:status] == 'Test' : response[:status] == '0'
        response[:message] = response[:success] ? "Successfully received the stock levels" : message_from(response[:error_message])

        response
      end

    end
  end
end