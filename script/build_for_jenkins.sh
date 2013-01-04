#!/bin/bash

readonly RAILS_ENV="test"

# Jenkins build script
gem install bundler --no-ri --no-rdoc
RAILS_ENV=${RAILS_ENV} bundle install --path vendor/bundle
RAILS_ENV=${RAILS_ENV} bundle exec rake db:create
RAILS_ENV=${RAILS_ENV} bundle exec rake db:migrate
RAILS_ENV=${RAILS_ENV} bundle exec rspec

rm -rf reports
mkdir -m 777 reports/
