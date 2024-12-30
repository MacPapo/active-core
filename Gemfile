source "https://rubygems.org"

ruby "3.3.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.3", ">= 7.1.3.4"
gem "rails-i18n", "~> 7.0"

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 2.2'
gem "activerecord-enhancedsqlite3-adapter", "~> 0.8.0"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

gem "devise", "~> 4.9"
gem "devise-i18n", "~> 1.12"

gem "csv", "~> 3.3"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Bundle and process JS
gem "jsbundling-rails", "~> 1.3"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

gem "discard", "~> 1.3"

gem "receipts", "~> 2.4"

gem "solid_queue"

gem "mission_control-jobs", "~> 0.3.1"

gem "sprockets-rails", "~> 3.5"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Vaildate phone numbers
gem "phonelib", "~> 0.8.9"

# Add pagination to queries
gem "pagy", "~> 8.6"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
  gem "faker", "~> 3.4"
  gem "pry", "~> 0.14.2"
  gem "pry-rails", "~> 0.3.11"

  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem "factory_bot_rails", "~> 6.4"
  gem "rspec-rails", "~> 6.1"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
