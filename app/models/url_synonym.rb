class UrlSynonym < ApplicationRecord

  REASONS = ["split"]

  belongs_to :species

  scope :different_name, -> { where(reason: nil) }
  scope :splits, -> { where(reason: "split") }

end
