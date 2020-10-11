# frozen_string_literal: true

class UrlSynonym < ApplicationRecord

  REASONS = ["split", "lump"]

  belongs_to :species

  scope :different_name, -> { where(reason: nil) }
  scope :splits, -> { where(reason: "split") }
  scope :lumps, -> { where(reason: "lump") }

end
