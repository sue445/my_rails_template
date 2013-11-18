if ENV["LOCAL_REPO"] == "1"
  REPO_URL = File.expand_path(File.dirname(__FILE__))
else
  REPO_URL = "https://raw.github.com/sue445/my_rails_template/master"
end

gems = {}
gems[:capistrano] = yes? "Would you like to install capistrano?"
gems[:jenkins]    = yes? "Would you like to install Jenkins CI tools?"

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
  gem 'annotate', ">=2.5.0", require: false
  gem "better_errors"
  gem "binding_of_caller"
  gem "view_source_map", "0.0.3"
end

label "testing"
gem_group :test, :development do
  gem "rspec-rails"
  gem "factory_girl_rails", "~> 4.1.0"
  gem "rspec-parameterized"

  gem "pry", "~> 0.9.10"
  gem "pry-remote", "~> 0.1.6"
  gem "pry-nav", "~> 0.2.3"
  gem "pry-rails", "~> 0.2.2"

  gem "database_cleaner"
end

label "guard"
append_to_file "Gemfile" do
  <<-EOS

group :development do
  gem 'guard-rspec'

  # ref. https://github.com/guard/guard#efficient-filesystem-handling
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false

  # Runs on Mac OS X
  gem 'growl'

  # Runs on Linux, FreeBSD, OpenBSD and Solaris
  #gem 'libnotify'

  # Runs on Windows
  #gem 'rb-notifu'
end

  EOS
end

if gems[:jenkins]
  label "Jenkins CI"
  gem_group :test do
    gem "simplecov", :require => false
    gem "simplecov-rcov", :require => false
    gem "ci_reporter", "~> 1.8.4"
  end

  copy_from_repo "script/build_for_jenkins.sh"
  copy_from_repo "script/generate_rdoc.sh"
  get "https://gist.github.com/sue445/5140150/raw/plot-rspec-slowest-examples.rb", "script/plot-rspec-slowest-examples.rb"

  chmod "script/generate_rdoc.sh", 0755

  run "cp config/database.yml config/database.yml.jenkins"
  insert_into_file "Rakefile", "require 'ci/reporter/rake/rspec' if Rails.env.test?\n", :after => "require File.expand_path('../config/application', __FILE__)\n"
end

if gems[:capistrano]
  label "Deploy with Capistrano"
  gem_group :development do
    gem "capistrano"
    gem "capistrano-ext"
    gem "capistrano_rsync_with_remote_cache"
    gem "capistrano_colors"
    gem "capistrano-tagging", "~> 0.1.0"
    gem "capistrano-colorized-stream"
  end
end


if gems[:bootstrap]
  label "twitter-bootstrap-rails"

  gem "less-rails"
  gem "libv8", "~> 3.11.8"
  gem "twitter-bootstrap-rails", ">= 2.1.3"
  gem "therubyracer", ">= 0.10.2", :platform => :ruby
end

remove_file "test/"
copy_from_repo "spec/spec_helper.rb"
copy_from_repo "spec/factories/sequences.rb"
copy_from_repo ".rspec"

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

capify! if gems[:capistrano]

# ref. https://github.com/tachiba/rails3_template/blob/master/app_template.rb

#
# Generators
#
if gems[:bootstrap]
  generate 'bootstrap:install'

  if yes? "Would you like to create FIXED layout?(yes=FIXED, no-FLUID)"
    generate 'bootstrap:layout application fixed -f'
  else
    generate 'bootstrap:layout application fluid -f'
  end

  get "https://gist.github.com/sue445/5261654/raw/ja.bootstrap.yml", "config/locales/ja.bootstrap.yml"
  #gsub_file "app/views/layouts/application.html.haml", /lang="en"/, %(lang="ja")

  remove_file "app/assets/stylesheets/scaffolds.css.scss"
end

run "bundle exec guard init"

#
# Git
#
git :init
git :add => '.'
git :commit => '-am "Initial commit"'

