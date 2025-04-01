# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development, :test do
  gem "appraisal"
  gem "bundler", "~> 2.6"
  gem "bundler-audit", "~> 0"
  gem "mocha", "~> 2.7"
  gem "rake", "~> 13.2"
  gem "rspec", "~> 3.13"
  gem "rubocop", "~> 1.75"

  # For connecting to a GKE cluster in development/test
  gem "googleauth"
end
