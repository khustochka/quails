# frozen_string_literal: true

class SpeciesSplit < ApplicationRecord
  belongs_to :superspecies, class_name: "Species", inverse_of: :splits_where_it_is_superspecies
  belongs_to :subspecies, class_name: "Species", inverse_of: :splits_where_it_is_subspecies
end
