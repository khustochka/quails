# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
# Intentionally disabled in production. The gain is minimal, but its cache eats precious space.
begin
  require "bootsnap/setup" unless ENV["RAILS_ENV"] == "production"
rescue LoadError
end
