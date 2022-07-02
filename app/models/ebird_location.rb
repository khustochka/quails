# frozen_string_literal: true

class EbirdLocation < ApplicationRecord
  has_many :loci, dependent: :nullify

  def to_label
    name
  end
end
