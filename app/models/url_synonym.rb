# frozen_string_literal: true

class UrlSynonym < ApplicationRecord
  REASONS = ["split", "lump"]

  belongs_to :species

  scope :different_name, -> { where(reason: nil) }
  scope :splits, -> { where(reason: "split") }
  scope :lumps, -> { where(reason: "lump") }

  validates :name_sci, uniqueness: true, presence: true, format: /\A[A-Z][a-z]+ [a-z]+\Z/
  validate :names_are_different

  private
  def names_are_different
    if name_sci == species.name_sci
      errors.add(:name_sci, "should be different from the species name.")
    end
  end
end
