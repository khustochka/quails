# frozen_string_literal: true

if ENV['AIRBRAKE_API_KEY'] && ENV['AIRBRAKE_HOST']
  require 'resque/failure/multiple'
  require 'resque/failure/redis'
  require 'airbrake/resque' # use failure backend from airbrake, not from resque

  Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
  Resque::Failure.backend = Resque::Failure::Multiple
end
