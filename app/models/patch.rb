class Patch  < Locus
  default_scope { where(patch: true) }
end
