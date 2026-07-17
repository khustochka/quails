# frozen_string_literal: true

# Stands in for a hardcoded country (ukraine, usa, ...) whose Locus row is not
# in the database yet, so its gallery/checklist page still renders — with the
# i18n title and static thumbnail keyed off the slug — instead of 404ing.
# Only built for slugs the routes already constrain to the known set.
class PlaceholderCountry
  attr_reader :slug

  def initialize(slug)
    @slug = slug
  end

  def name_en
    slug.tr("_", " ").split.map(&:capitalize).join(" ")
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
