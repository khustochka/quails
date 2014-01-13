class Country < Locus
  default_scope { where(parent_id: nil).order(:public_index) }

  def self.quick_find(slug)
    Rails.cache.fetch("records/loci/country/#{slug}") do
      Country.find_by_slug!(slug)
    end
  end
end
