class Country < Locus
  default_scope { where(parent_id: nil).order(:public_index) }
end
