# README

## Intro

Shopify provides APIs for both fulfillment and carrier service creation and management.

Carrier Services provide shipping rates to Shopify, and are presumably backed by an actual shipping service. FedEx, UPS, USPS, Royal Mail, etc. are all carriers that might want to use this API.

The terms 'carrier' and 'shipping' are often used interchangably.

Fulfillment Services are responsible for fulfilling orders. This involves being notified when an order is placed, and updating Shopify about order statuses and product inventory levels.

This app provides an example of using both.

The sections below outline the steps required to set up an app of your own to provide fulfillment or carrier serivces.

The workflow looks like this:
1. Create an app
2. Register your app as a carrier/fulfillment service, and subscribe to relevant notifications
3. Provide specific endpoints for Shopify to send order info to to trigger fulfillment, get shipping rates, or ask for inventory levels.

## Setup  

### App Creation:

1. Sign up as a [Shopify Partner](http://partners.shopify.com).
2. Request beta access by emailing [apps@shopify.com](mailto:apps@shopify.com). Tell us what you're planning on building as well as the email associated with your Partners account.
3. Create an app through the Partners Dashboard. See our [Development Guide](http://wiki.shopify.com/Shopify_App_Development) for more info.

### Steps to set up a fulfillment service:

1. Add the `write_fulfillments` permission to your [requested scopes](http://api.shopify.com/authentication.html)
2. On install, create a new fulfillment service. It needs the following params:

  * `name` - The name of your service as seen by merchants and their customers
  * `handle` - The URL-compatible version of your service's name
  * `inventory_management` - Does your service keep track of product inventory and provid updates to Shopify?
  * `callback_url` (If doing inventory checks) - The endpoint that Shopify should hit to get inventory and tracking updates
  * `tracking_support` - Does your service provide tracking numbers for packages?
  * `requires_shipping_method` - Do products fulfilled by your service require physical shipping?

  Example cURL request to Shopify:

  `curl -X POST -d @fulfillment_service.json -H "Content-Type:application/json"
  http://myshop.myshopify.com/admin/fulfillment_services`

  fulfillment_service.json:
  <pre><code>{
      'name': 'My Fulfillment Service',
      'handle': 'my_fulfillment_service',
      'callback_url': 'http://myapp.com',
      'inventory_management': true,
      'tracking_support': true,
      'requires_shipping_method': true
  }</code></pre>
3. Subscribe to `fulfillments/create` and `fulfillments/update` webhooks using the [Webhook API](http://api.shopify.com/webhook.html).
4. Expose the following GET endpoints, rooted at the `callback_url` you defined when creating the service:
  * `/fetch_tracking_numbers`: expects a list of Shopify order IDs, returns the tracking numbers for those orders.
      * Example request from Shopify:

          `http://myapp.com/fetch_tracking_numbers?order_ids[]=1&order_ids[]=2&order_ids[]=3`

      * Example response:

          <pre><code>{
              'tracking_numbers': {
                '1': 'qwerty',
                '2': 'asdfg',
                '3': 'zxcvb'
              },
              'message': 'Successfully received the tracking numbers',
              'success': true
          }</code></pre>
  * `/fetch_stock`: Expects a SKU and a shop name, returns the inventory level for that SKU
      * Example request:

          `https://myapp.com/fetch_stock?sku=123&shop=testshop.myshopify.com`

      * Example response:

          `{'123': 1000}`

### Steps to set up a carrier/shipping service:

1. Add the `write_shipping` permission to your requested scopes
2. On install, create a new carrier service through the API. It needs the following params:
  * `name` - The name of your service
  * `callback_url` - The endpoint Shopify should hit for shipping rates
  * `service_discovery` - Should merchants be able to send dummy data to your service through the Shopify Admin to see examples of your shipping rates?

  Example cURL request:

  `curl -X POST -d @carrier_service.json -H "Content-Type:application/json"
  http://myshop.myshopify.com/admin/carrier_services`

  carrier_service.json:
  <pre><code>{
      'name': 'My Carrier Service',
      'callback_url': 'http://myapp.com',
      'service_discovery': true
    }
  </code></pre>
3. Your `callback_url` should be a public endpoint that expects a request for shipping rates and should return an array of applicable rates.
      * Example request from Shopify:
      <pre><code>{
              "rate": {
                "origin": {
                  "country": "CA", 
                  "postal_code": "K1S4J3", 
                  "province": "ON", 
                  "city": "Ottawa", 
                  "name": "", 
                  "address1": "520 Cambridge Street South", 
                  "address2": "", 
                  "address3": "", 
                  "phone": "", 
                  "fax": "", 
                  "address_type": "", 
                  "company_name": ""
                }, 
                "destination": {
                  "country": "CA", 
                  "postal_code": "K1S 3T7", 
                  "province": "ON", 
                  "city": "Ottawa", 
                  "name": "Jason Normore", 
                  "address1": "520 Cambridge Street South Apt. 5", 
                  "address2": "", 
                  "address3": "", 
                  "phone": "7097433959", 
                  "fax": "", 
                  "address_type": "", 
                  "company_name": ""
                }, 
                "items": [
                  {
                    "name": "My Product 3", 
                    "sku": "", "quantity": 1, 
                    "grams": 1000, 
                    "price": 2000, 
                    "vendor": "TestVendor", 
                    "requires_shipping": true, 
                    "taxable": true, 
                    "fulfillment_service": "manual"
                  }
                ], 
                "currency": "CAD"
              }
            }
      </code></pre>
      * Example response:
      <pre><code>{
              "rates": [ {
                  'service_name': 'canadapost - overnight',
                  'service_code': 'ON',
                  'total_price': '12.95',
                  'currency': 'CAD'
                },
                {
                  'service_name': 'fedex - 2 day ground',
                  'service_code': '1D',
                  'total_price': '29.34',
                  'currency': 'USD'
                }
              ]
            }
      </code></pre>