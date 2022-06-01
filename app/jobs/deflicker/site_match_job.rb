# frozen_string_literal: true

require "deflicker/service"

module Deflicker
  class SiteMatchJob < ApplicationJob
    def perform
      Deflicker::Service.new.match_to_site
    end
  end
end
