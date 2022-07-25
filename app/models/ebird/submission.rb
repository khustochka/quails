# frozen_string_literal: true

module EBird
  class Submission < ApplicationRecord
    belongs_to :ebird_file, class_name: "EBird::File", inverse_of: :ebird_submissions
    belongs_to :card
  end
end
