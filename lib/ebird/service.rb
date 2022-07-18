# frozen_string_literal: true

require "ebird/client"

module Ebird
  class Service
    class << self
      def preload
        client = Ebird::Client.new
        client.authenticate
        [Time.current, client.fetch_unsubmitted_checklists].tap do |time, checklists|
          Rails.cache.write("ebird/last_preload", time)
          Rails.cache.write("ebird/preloaded_checklists", checklists)
        end
      end
    end
  end
end
