# frozen_string_literal: true

module Deflicker
  class JournalsController < ApplicationController
    administrative

    def index
      @journals = journals
      stats = @journals.map do |journal|
        base = Deflicker::JournalEntry.where(journal: journal)
        with_flickers = base.where.not(flickr_ids: [])
        fixed = base.where(fixed: true)
        [journal,
          {
            "Total" => base.size,
            "With flickers" => with_flickers.size,
            "Fixed" => fixed.size,
            "Unfixed" => with_flickers.size - fixed.size,
          },]
      end
      @stats = Hash[stats]
    end

    private

    def journals
      Deflicker::JournalEntry.distinct(:journal)
    end
  end
end
