# frozen_string_literal: true

class SpeciesSplit < ApplicationRecord

  belongs_to :superspecies, class_name: "Species"
  belongs_to :subspecies, class_name: "Species"

end
