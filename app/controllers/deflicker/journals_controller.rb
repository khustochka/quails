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

    def start
      journal = params["journal"]
      passwd = params["passwd"]

      session[:journal_passwd] = passwd

      redirect_to deflicker_journal_entry_path(journal)
    end

    def entry
      @journal = params["journal"]

      @entry = Deflicker::JournalEntry.where(journal: @journal).where.not(fixed: true).where.not(flickr_ids: []).first

      @fix = Deflicker::EntryFix.new(@entry, session[:journal_passwd])
    end

    def mark_as_fixed
      @journal = params["journal"]

      @entry = Deflicker::JournalEntry.where(journal: @journal).find(params["entry_id"])
      @entry.fixed = true
      @entry.save!

      redirect_to deflicker_journal_entry_path(@journal)
    end

    private

    def journals
      Deflicker::JournalEntry.distinct(:journal)
    end
  end
end
