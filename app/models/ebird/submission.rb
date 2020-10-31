# frozen_string_literal: true

class Ebird::Submission < ApplicationRecord

  belongs_to :ebird_file, class_name: "Ebird::File", foreign_key: "ebird_file_id", inverse_of: :ebird_submissions
  belongs_to :card

end
