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

  def self.config
    @_config ||= Class.new(ActiveSupport::Configurable::Configuration).new
  end
end
