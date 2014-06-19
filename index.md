---
layout: index
---

# README

## Intro
Shopify wants you to appear in the Shopify App Store as a fulfillment partner. This will allow Shopify merchants to use your app to provide shipping rates, fulfill orders, update those orders with tracking numbers, and keep track of inventory. Your app will act as a middle layer between Shopify and your fulfillment service. This document and sample application detail the steps necessary to use Shopify's fulfillment and carrier services APIs.


### The Fulfillment API

Fulfillment Services are responsible for fulfilling orders. This involves being notified by Shopify when an order is placed, and updating Shopify about order statuses and product inventory levels.

API doc at: http://docs.shopify.com/api/fulfillmentservice

### The Carrier Service API

Carrier Services provide shipping rates to Shopify, and are presumably backed by an actual shipping service. FedEx, UPS, USPS, Royal Mail, etc. are all carriers that might want to use this API.

The terms 'carrier' and 'shipping' are often used interchangably.

API doc at: http://docs.shopify.com/api/carrierservice

## Setup

1. Register as a [Shopify Partner](http://partners.shopify.com)
2. Create an app through the Partners Dashboard. See our [Development Guide](http://docs.shopify.com/api/the-basics/getting-started) for more info.
3. Register a fulfillment service. Directions are included below.
4. Register a carrier service and subscribe to relevant notifications. Directions are included below.
5. Provide specific endpoints for Shopify to send order info to trigger fulfillment, get shipping rates, or ask for inventory levels.

### Steps to set up a fulfillment service

#### Setting fulfillments permissions

Add the `write_fulfillments` permission to your [requested scopes](http://docs.shopify.com/api/tutorials/oauth).

#### Register a new fulfillment service

On installation, create a new fulfillment service. You will need to provide the following parameters:

  * `name` - The name of your service as seen by merchants and their customers
  * `handle` - The URL-compatible version of your service's name
  * `inventory_management` - Does your service keep track of product inventory and provid updates to Shopify?
  * `callback_url` (If doing inventory checks) - The endpoint that Shopify should hit to get inventory and tracking updates
  * `tracking_support` - Does your service provide tracking numbers for packages?
  * `requires_shipping_method` - Do products fulfilled by your service require physical shipping?

Here’s an example of a request payload to make a new fulfillment service:
  
  `fulfillment_service.json`:
  
    { "fulfillment_service": 
      {
        "name": "My Fulfillment Service",
        "handle": "my_fulfillment_service",
        "callback_url": "http://myapp.com",
        "inventory_management": true,
        "tracking_support": true,
        "requires_shipping_method": true,
        "format": "json"
      }
    }

Here’s an example cURL request to Shopify that uses that `fulfillment_service.json` payload:

  `curl -X POST -d @fulfillment_service.json
        -H "Accept:application/json"
        -H "Content-Type:application/json"
        -H "X-Shopify-Access-Token:THE_AUTH_TOKEN_GOES_HERE"
        http://myshop.myshopify.com/admin/fulfillment_services`

#### Subscribe to fulfillment webhooks

Subscribe to `fulfillments/create` and `fulfillments/update` webhooks using the [Webhook API](http://docs.shopify.com/api/tutorials/webhooks).

#### Provide fulfillment endpoints

Expose the two following GET endpoints, rooted at the `callback_url` you defined when creating the service:

  * `/fetch_tracking_numbers`: expects a list of Shopify order IDs, returns the tracking numbers for those orders.
  * `/fetch_stock`: Expects a SKU and a shop name, returns the inventory level for that SKU
  
Example `/fetch_tracking_numbers` request from Shopify:

    http://myapp.com/fetch_tracking_numbers?order_ids[]=1&order_ids[]=2&order_ids[]=3

Example `/fetch_tracking_numbers` response:

      { "tracking_numbers": {
          "1": "qwerty",
          "2": "asdfg",
          "3": "zxcvb"
        },
        "message": "Successfully received the tracking numbers",
        "success": true
      }
      
Example `/fetch_stock` request:

    https://myapp.com/fetch_stock?sku=123&shop=testshop.myshopify.com

Example `/fetch_stock` response:

    {"123": 1000}

### Steps to set up a carrier/shipping service:
#### Setting permissions
Add the `write_shipping` permission to your [requested scopes](http://docs.shopify.com/api/tutorials/oauth).

#### Register a new shipping service

On install, create a new carrier service through the API. It needs the following paramseters:

  * `name` - The name of your service
  * `callback_url` - The endpoint Shopify should hit for shipping rates
  * `service_discovery` - Should merchants be able to send dummy data to your service through the Shopify Admin to see examples of your shipping rates?
  * `format` - json or xml


Here's an example of the request payload:

  carrier_service.json:
  
    { "carrier_service":
      {
        "name": "My Carrier Service",
        "callback_url": "http://myapp.com",
        "service_discovery": true
        "format": "json"
      }
    }


Example cURL request:

  `curl -X POST -d @carrier_service.json
        -H "Accept:application/json"
        -H "Content-Type:application/json"
        -H "X-Shopify-Access-Token:THE_AUTH_TOKEN_GOES_HERE"
        http://myshop.myshopify.com/admin/carrier_services`

#### Provide shipping endpoints
Your `callback_url` should be a public endpoint that expects a request for shipping rates and should return an array of applicable rates.

Example request from Shopify:
      
    {
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
                   "sku": "",
                   "quantity": 1,
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
                      
Example response:

    {
       "rates": [
           {
               'service_name': 'canadapost-overnight',
               'service_code': 'ON',
               'total_price': '12.95',
               'currency': 'CAD',
               'min_delivery_date': '2013-04-12 14:48:45 -0400',
               'max_delivery_date': '2013-04-12 14:48:45 -0400'
           },
           {
               'service_name': 'fedex-2dayground',
               'service_code': '1D',
               'total_price': '29.34',
               'currency': 'USD',
               'min_delivery_date': '2013-04-12 14:48:45 -0400',
               'max_delivery_date': '2013-04-12 14:48:45 -0400'
           },
           {
               'service_name': 'fedex-2dayground',
               'service_code': '1D',
               'total_price': '29.34',
               'currency': 'USD',
               'min_delivery_date': '2013-04-12 14:48:45 -0400',
               'max_delivery_date': '2013-04-12 14:48:45 -0400'
           }
       ]
    }
