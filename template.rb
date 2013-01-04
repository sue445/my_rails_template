#REPO_URL = "~/workspace/rails/my_rails_template"
REPO_URL = "https://raw.github.com/sue445/my_rails_template/master"

gems = {}

def copy_from_repo(path)
  get "#{REPO_URL}/#{path}", path
end

# append comment line to Gemfile
def label(str)
  append_to_file "Gemfile", "\n# #{str}"
end

label "testing"
gem_group :test, :development do
  gem "rspec-rails", "~> 2.12.0"
  gem "factory_girl_rails", "~> 4.1.0"
  gem "rspec-parameterized", "~> 0.0.7"

  gem "pry", "~> 0.9.10"
  gem "pry-remote", "~> 0.1.6"
  gem "pry-nav", "~> 0.2.3"
  gem "pry-rails", "~> 0.2.2"

  gem "spork-rails", "~> 3.2.1"

  gem "database_cleaner"
end

label "guard"
append_to_file "Gemfile" do
  <<-EOS

group :development do
  gem "guard", ">= 0.6.2"

  require "rbconfig"
  HOST_OS = RbConfig::CONFIG["host_os"]
  case HOST_OS
    when /darwin/i
      gem "rb-fsevent"
      gem "growl"
    when /linux/i
      gem "libnotify"
      gem "rb-inotify"
    when /mswin|windows/i
      gem "rb-fchange"
      gem "win32console"
      gem "rb-notifu"
  end

  gem "guard-bundler", ">= 0.1.3"
  gem "guard-rails", ">= 0.0.3"
  gem "guard-rspec", ">= 0.4.3"
  #gem "guard-cucumber", ">= 0.6.1"
end

  EOS
end

if yes? "Would you like to install Jenkins CI tools?"
  label "Jenkins CI"
  gem_group :test do
    gem "simplecov", :require => false
    gem "simplecov-rcov", :require => false
    gem "rails_best_practices", "~> 1.11.1"
  end

  copy_from_repo "script/build_for_jenkins.sh"
  copy_from_repo "script/rails_best_practices.sh"

  chmod "script/build_for_jenkins.sh", 0755
  chmod "script/rails_best_practices.sh", 0755
end

if yes? "Would you like to install capistrano?"
  capify!

  label "Deploy with Capistrano"
  gem_group :development do
    gem "capistrano"
    gem "capistrano-ext"
    gem "capistrano_rsync_with_remote_cache"
    gem "capistrano_colors"
  end
end

gems[:bootstrap] = yes? "Would you like to install twitter-bootstrap-rails?"

if gems[:bootstrap]
  label "twitter-bootstrap-rails"

  gem_group :assets do
    gem "less-rails"
    gem "libv8", "~> 3.11.8"
    gem "twitter-bootstrap-rails", ">= 2.1.3"
    gem "therubyracer", ">= 0.10.2", :platform => :ruby
  end
end

remove_file "README.rdoc"
remove_file "test/"


copy_from_repo "spec/spec_helper.rb"
copy_from_repo ".rspec"


append_to_file ".gitignore" do
  <<-EOS
/vendor/bundle/
/reports/
  EOS
end

# ref. https://github.com/tachiba/rails3_template/blob/master/app_template.rb

#
# Generators
#
if gems[:bootstrap]
  generate 'bootstrap:install'

  if yes?("Would you like to create FIXED layout?(yes=FIXED, no-FLUID)")
    generate 'bootstrap:layout application fixed -f'
  else
    generate 'bootstrap:layout application fluid -f'
  end

  gsub_file "app/views/layouts/application.html.haml", /lang="en"/, %(lang="ja")
end

run "bundle install --path vendor/bundle"
#run "bundle install"

run "bundle exec guard init"

#
# Git
#
git :init
git :add => '.'
git :commit => '-am "Initial commit"'

