# frozen_string_literal: true

require "quails/env"
require "quails/revision"

module Quails
  LICENSE_YEAR = 2026

  def self.env
    @env ||= Env.new
  end

  # Serve stored image variants as direct (public) storage URLs instead of
  # /rails/active_storage/representations/redirect/... routes, falling back to
  # the redirect route for variants that are not processed yet.
  def self.direct_variant_urls?
    ENV["QUAILS_DIRECT_VARIANT_URLS"].in?(%w(true 1))
  end

  def self.revision
    @revision ||= Revision.get
  end

  def self.unique_key
    config[:unique_key]
  end

  def self.config
    @config ||= {}
  end
end
