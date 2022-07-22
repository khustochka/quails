# frozen_string_literal: true

module Ebird
  class File < ApplicationRecord
    STATUSES = %w(NEW POSTED REMOVED INVALID)

    TRANSITIONS = {
      "NEW" => %w(POSTED REMOVED INVALID),
      "POSTED" => %w(REMOVED INVALID),
      "REMOVED" => %w(POSTED INVALID),
      "INVALID" => [],
    }

    class Transition < Struct.new(:file_id, :status)
      def to_partial_path
        "transition"
      end
    end

    validates :name, presence: true
    validates :status, inclusion: STATUSES, allow_blank: false
    validates :cards, presence: true
    validate :cards_effort, on: :create

    has_many :ebird_submissions, class_name: "Ebird::Submission", foreign_key: "ebird_file_id",
      dependent: :delete_all, inverse_of: :ebird_file
    has_many :cards, -> { order(:observ_date) }, through: :ebird_submissions, inverse_of: :ebird_files

    # Is there any card updated after file generation
    def outdated?
      cards.exists?(["updated_at > ?", created_at])
    end

    def transitions
      TRANSITIONS[status].map { |t| Transition.new(id, t) }
    end

    def cards_effort
      cards.each { |r| r.valid?(:ebird_post) }
      if cards.any? { |r| r.errors.any? }
        errors.add(:cards, "some are invalid")
      end
    end

    def full_name
      "%s.csv" % name
    end
  end
end
