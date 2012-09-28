web: bundle exec rails server thin -p $PORT -e $RACK_ENV
worker: bundle exec rake environment resque:work QUEUE=* 