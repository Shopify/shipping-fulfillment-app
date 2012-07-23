require 'date'

module ActiveMerchant
  module Fulfillment
    class ShipwireService < Service

      def fetch_tracking_updates
        request = buid_tracking_request
        data = ssl_post(SERVICE_URLS[:tracking], "#{POST_VARS[:tracking]}=#{CGI.escape(request)}")

        response = parse_tacking_updates_response(data)
      end

      def build_tracking_updates_request
        xml = Builder::XmlMarkup.new
        xml.instruct!
        xml.declare! :DOCTYPE, :InventoryStatus, :SYSTEM, SCHEMA_URLS[:inventory]
        xml.tag! 'TrackingUpdate' do
          add_credentials(xml)
          xml.tag! 'Server', test? ? 'Test' : 'Production'
          xml.tag! 'Bookmark', 3 # TODO: email about testing this
        end
      end

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

    end
  end
end