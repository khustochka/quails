# frozen_string_literal: true

require "deflicker/service"

module Deflicker
  class FlickrLoadJob < ApplicationJob

    def perform
      Deflicker::Service.new.load_data
    end

  end
end
