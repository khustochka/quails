# frozen_string_literal: true

# Stands in for a hardcoded country (ukraine, usa, ...) whose Locus row is not
# in the database yet, so its gallery/checklist page still renders — with the
# i18n title and static thumbnail keyed off the slug — instead of 404ing.
# Only built for slugs the routes already constrain to the known set.
class PlaceholderCountry
  attr_reader :slug

  # A slug counts as a known hardcoded country iff it has a lifelist title in
  # i18n. This is what distinguishes an empty-but-valid country page (render a
  # placeholder) from an unknown one (404).
  def self.hardcoded?(slug)
    I18n.exists?("lifelist.title.country.#{slug}", I18n.default_locale)
  end

  def initialize(slug)
    @slug = slug
  end

  def name_en
    slug.tr("_", " ").split.map(&:capitalize).join(" ")
  end

  # No DB row, so no localized bare country name is available; the lifelist
  # title falls back to the full "<Country> List" phrase from i18n.
  def name
    I18n.t("lifelist.title.country.#{slug}")
  end

  def to_param
    slug
  end

  def subregion_ids
    []
  end

  def checklist(_to_include = [])
    LocalSpecies.none.extending(SpeciesArray)
  end
end
