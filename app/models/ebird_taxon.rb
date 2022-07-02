# frozen_string_literal: true

class EbirdTaxon < ApplicationRecord
  localized_attr :name

  acts_as_list column: :index_num

  # Associations

  belongs_to :parent, class_name: "EbirdTaxon", optional: true
  has_many :children, class_name: "EbirdTaxon", foreign_key: "parent_id"
  has_one :taxon

  # Scopes
  scope :category_species, -> { where(category: "species") }

  # Parameters

  # temporarily using ebird code
  def to_param
    ebird_code
  end

  def nearest_species
    if category == "species"
      self
    else
      parent
    end
  end

  def promote(species: nil)
    return taxon if taxon

    ActiveRecord::Base.transaction do
      # If parent exists promote it
      promoted_parent = parent&.promote(species: species)

      # Creating taxon
      attr_hash = attributes.slice("name_sci", "name_en", "ebird_code", "category", "order", "family")
      prev_index_num =
        Taxon.
          joins("INNER JOIN ebird_taxa on ebird_taxa.id = taxa.ebird_taxon_id").
          where("ebird_taxa.index_num < ?", index_num).order("taxa.index_num DESC").
          limit(1).pluck("taxa.index_num").first
      new_index_num = prev_index_num ? prev_index_num + 1 : 1
      attr_hash[:index_num] = new_index_num
      if promoted_parent
        attr_hash[:parent_id] = promoted_parent.id
        attr_hash[:species_id] = promoted_parent.species_id
      end

      new_taxon = create_taxon!(attr_hash)
      save!

      # For taxonomy update (lumps): if there were already promoted children taxa of unpromoted parent.

      children.map(&:taxon).compact.each { |tx| tx.update(parent_id: new_taxon.id) }

      # Create or update species if necessary

      if category == "species"
        new_taxon.lift_to_species(species: species)
      end

      # Return the taxon
      new_taxon
    end
  end

  alias_method :find_or_promote_to_taxon, :promote
end
