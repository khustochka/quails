class Country < Locus
  default_scope { where(loc_type: 0) }
end