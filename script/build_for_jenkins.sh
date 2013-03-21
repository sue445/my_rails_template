#!/bin/bash

readonly JENKINS_RAILS_ENV="test"

# Jenkins build script

run()
{
  command=$1
  echo "$command"

  eval $command

  # if error code returned, exit this script with error code
  RET=$?
  if [ $RET -ne 0 ]; then
    exit $RET
  fi
}

run "cp config/database.yml.jenkins config/database.yml"
run "gem install bundler --no-ri --no-rdoc"


#########################
echo "bundle install --path vendor/bundle"

bundle install --path vendor/bundle

RET=$?
if [ $RET -ne 0 ]; then
  # if failed 'bundle install', run 'bundle update'
  run "bundle update"
fi

run "RAILS_ENV=${JENKINS_RAILS_ENV} bundle exec rake db:create"
run "RAILS_ENV=${JENKINS_RAILS_ENV} bundle exec rake db:migrate"

# if you use mysql_partitioning, use don't use "rake spec". because primary key is dropped
#run "RAILS_ENV=${JENKINS_RAILS_ENV} bundle exec rake ci:setup:rspec spec"

run "rm -rf reports"
run "mkdir -m 777 reports/"

run "RAILS_ENV=${JENKINS_RAILS_ENV} bundle exec rspec --profile > reports/rspec-console.log"

exit 0
