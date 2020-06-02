class Country < Locus
  default_scope { where(loc_type: 'country').order(:public_index) }
end
