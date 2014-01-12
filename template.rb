if ENV["LOCAL_REPO"] == "1"
  REPO_URL = File.expand_path(File.dirname(__FILE__))
else
  REPO_URL = "https://raw.github.com/sue445/my_rails_template/master"
end

gems = {}
gems[:guard]      = yes? "Would you like to install guard?"
gems[:capistrano] = yes? "Would you like to install capistrano?"
gems[:jenkins]    = yes? "Would you like to install Jenkins CI tools?"
gems[:bootstrap]  = yes? "Would you like to install twitter-bootstrap-rails?"

def copy_from_repo(path)
  get "#{REPO_URL}/#{path}", path
end

# append comment line to Gemfile
def label(str)
  append_to_file "Gemfile", "\n# #{str}"
end

gem "slim-rails"

label "dev tool"
gem_group :development do
  gem 'annotate', ">=2.6.0", require: false
  gem "better_errors"
  gem "binding_of_caller"
  gem "view_source_map", "0.0.3"
end

label "testing"
gem_group :test, :development do
  gem "rspec-rails", "~> 3.0.0.beta1"
  gem "rspec-collection_matchers", "~> 0.0.2"
  gem "rspec-its", "1.0.0.pre"
  gem "rspec-parameterized", github: "sue445/rspec-parameterized", branch: "rspec-3.0.0.beta1"
  gem "factory_girl_rails", "~> 4.1.0"

  gem "pry"       , "~> 0.9.12.4"
  gem "pry-remote", "~> 0.1.7"
  gem "pry-nav"   , "~> 0.2.3"
  gem "pry-rails" , "~> 0.3.2"

  gem "database_rewinder", "~> 0.0.2"
end

if gems[:guard]
  label "guard"
    append_to_file "Gemfile" do
      <<-EOS

group :development do
  gem 'guard-rspec'

  # Runs on Mac OS X
  gem 'growl'

  # Runs on Linux, FreeBSD, OpenBSD and Solaris
  #gem 'libnotify'

  # Runs on Windows
  #gem 'rb-notifu'
end

    EOS
  end
end

if gems[:jenkins]
  label "Jenkins CI"
  gem_group :test do
    gem "simplecov", :require => false
    gem "simplecov-rcov", :require => false
    gem "ci_reporter", "~> 1.8.4"
  end

  copy_from_repo "script/build_for_jenkins.sh"
  get "https://gist.github.com/sue445/5140150/raw/plot-rspec-slowest-examples.rb", "script/plot-rspec-slowest-examples.rb"

  run "cp config/database.yml config/database.yml.jenkins"
  insert_into_file "Rakefile", "require 'ci/reporter/rake/rspec' if Rails.env.test?\n", :after => "require File.expand_path('../config/application', __FILE__)\n"
end

if gems[:capistrano]
  label "Deploy with Capistrano"
  gem_group :development do
    gem "capistrano", "~> 3.0.1"
    gem 'capistrano-rails', '~> 1.1.0'
    gem "capistrano_rsync_with_remote_cache"
  end
end


if gems[:bootstrap]
  label "twitter-bootstrap-rails"

  gem "less-rails"
  gem "libv8", "~> 3.11.8"
  gem "twitter-bootstrap-rails", github: "seyhunak/twitter-bootstrap-rails", branch: "bootstrap3"
  gem "therubyracer", ">= 0.10.2", :platform => :ruby
end

remove_file "test/"
copy_from_repo "spec/spec_helper.rb"
copy_from_repo "spec/factories/sequences.rb"
copy_from_repo "spec/models/sample_spec.rb"
copy_from_repo ".rspec"
copy_from_repo "lib/tasks/auto_annotate_models.rake"

get "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml", "config/locales/ja.yml"

# customize .gitignore
remove_file ".gitignore"
get "https://raw.github.com/RailsApps/rails-composer/master/files/gitignore.txt", ".gitignore"
append_to_file ".gitignore" do
  <<-EOS
/reports/
/coverage/
/db/schema.rb
  EOS
end

run "bundle install --path vendor/bundle"
#run "bundle install"

run "bundle exec cap install" if gems[:capistrano]

# ref. https://github.com/tachiba/rails3_template/blob/master/app_template.rb

#
# Generators
#
if gems[:bootstrap]
  generate 'bootstrap:install less'
  generate 'bootstrap:layout application'

  get "https://gist.github.com/sue445/5261654/raw/ja.bootstrap.yml", "config/locales/ja.bootstrap.yml"

  remove_file "app/assets/stylesheets/scaffolds.css.scss"
end

run "bundle exec guard init" if gems[:guard]

#
# Git
#
git :init
git :add => '.'
git :commit => '-am "Initial commit"'

