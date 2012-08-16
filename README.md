shipwire-app
============

This app is the first step in factoring fulfillment services out of the shopify core.


Getting Started
===============

+After cloning run "bundle" and "rake db:setup"

+Add this line to your host file (for mac /private/etc/hosts):
127.0.0.1 localhost shop1.localhost shipwireapp

+Run your local version of shopify on port 3000
and the shipwire app on port 3001 ie. rails server -p 3001

+To see an example of a variant with inventory managed by shipwire go to http://localhost:3001/variants/1?product_title=Baseball

### Warren D is a G