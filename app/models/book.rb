# frozen_string_literal: true

class Book < ApplicationRecord

  has_many :legacy_taxa, -> {order "legacy_taxa.index_num"}

  # Parameters

  def to_param
    slug_was
  end

end
