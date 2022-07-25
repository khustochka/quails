# frozen_string_literal: true

class EBirdLocation < ApplicationRecord
  has_many :loci, dependent: :nullify

  def to_label
    name
  end
end
