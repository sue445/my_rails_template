#!/bin/bash -xe

readonly JENKINS_RAILS_ENV="test"
readonly JOB_COUNT=4

export LANG=ja_JP.UTF-8

# Jenkins build script
which ruby
ruby --version
cp config/database.yml.jenkins config/database.yml
gem install bundler --no-ri --no-rdoc


#########################
# handling bundle install error
set +e
bundle install --path vendor/bundle --jobs=${JOB_COUNT}

RET=$?
if [ $RET -ne 0 ]; then
  # if failed 'bundle install', run 'bundle update'
  bundle update
fi
set -e

rm -f log/*.log
bundle clean

RAILS_ENV=${JENKINS_RAILS_ENV} bundle exec rake db:create
RAILS_ENV=${JENKINS_RAILS_ENV} bundle exec rake db:migrate

rm -rf reports
mkdir -m 777 reports/

RAILS_ENV=${JENKINS_RAILS_ENV} bundle exec rspec --profile

# * if you use mysql_partitioning, use don't use `rake spec`. because primary key is dropped
# * `rake spec` can not use --profile
#RAILS_ENV=${JENKINS_RAILS_ENV} bundle exec rake ci:setup:rspec spec


exit 0
