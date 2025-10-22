# frozen_string_literal: true

require "quails/env"
require "quails/revision"

module Quails
  CURRENT_YEAR = 2025

  def self.env
    @env ||= Env.new
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
