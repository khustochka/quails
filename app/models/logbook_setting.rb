# frozen_string_literal: true

# Which lists of an area (life and/or year) are reported in the logbook.
# A nil +locus+ stands for the World.
class LogbookSetting < ApplicationRecord
  validates :locus_id, uniqueness: true

  invalidates Quails::CacheKey.lifelist

  belongs_to :locus, optional: true

  scope :enabled, -> { where(life: true).or(where(year: true)) }

  # Upserts settings given as { locus_id => { life:, year: } } (nil locus_id
  # for the World). Rows with both lists off are removed.
  def self.save_all(settings)
    transaction do
      settings.each do |locus_id, flags|
        life = ActiveModel::Type::Boolean.new.cast(flags[:life]) || false
        year = ActiveModel::Type::Boolean.new.cast(flags[:year]) || false
        if life || year
          find_or_initialize_by(locus_id: locus_id).update!(life: life, year: year)
        else
          where(locus_id: locus_id).destroy_all
        end
      end
    end
  end

  # Loci offered in the settings form, as [locus, nested] pairs: countries,
  # first-level subdivisions and lifelist loci that have observations, plus
  # any locus with an enabled setting. Non-country top-level loci go first,
  # then each country followed by its nested loci (subdivisions first).
  def self.offered_loci
    observed_ids = Locus.where(id: Card.select(:locus_id)).flat_map(&:path_ids).to_set
    candidates = Locus.where(loc_type: %w(country subdivision1))
      .or(Locus.where.not(public_index: nil))
      .to_a
      .select { |loc| observed_ids.include?(loc.id) }
    candidates |= Locus.where(id: enabled.where.not(locus_id: nil).select(:locus_id)).to_a

    countries, others = candidates.partition { |loc| loc.loc_type == "country" }
    country_ids = countries.to_set(&:id)
    nested, top = others.partition { |loc| loc.ancestor_ids.any? { |id| country_ids.include?(id) } }
    nested_by_country = nested.group_by { |loc| loc.ancestor_ids.find { |id| country_ids.include?(id) } }

    top.sort_by(&:name_en).map { |loc| [loc, false] } +
      countries.sort_by(&:name_en).flat_map do |country|
        children = nested_by_country.fetch(country.id, [])
          .sort_by { |loc| [loc.loc_type == "subdivision1" ? 0 : 1, loc.name_en] }
        [[country, false]] + children.map { |loc| [loc, true] }
      end
  end
end
