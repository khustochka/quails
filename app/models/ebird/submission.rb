# frozen_string_literal: true

module Ebird
  class Submission < ApplicationRecord
    belongs_to :ebird_file, class_name: "Ebird::File", inverse_of: :ebird_submissions
    belongs_to :card
  end
end
