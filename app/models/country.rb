class Country < Locus
  default_scope { where(loc_type: 'country').order(:public_index) }

  def self.quick_find(slug)
    Rails.cache.fetch("records/loci/country/#{slug}") do
      Country.find_by_slug!(slug)
    end
  end
end
