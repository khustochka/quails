# frozen_string_literal: true

#require 'species_parameterizer'

class Taxon < ApplicationRecord

  # invalidates CacheKey.gallery
  # invalidates CacheKey.checklist

  # extend SpeciesParameterizer

  localized_attr :name

  acts_as_list column: :index_num

  # validates :order, :presence => true
  # validates :family, :presence => true
  # validates :name_sci, :format => /\A[A-Z][a-z]+ [a-z]+\Z/, :uniqueness => {scope: :book_id}
  # validates :avibase_id, :format => /\A[\dA-F]{16}\Z/, :allow_blank => true
  # validates :species_id, uniqueness: {scope: :book_id}, :allow_blank => true

  # Associations
  belongs_to :parent, class_name: "Taxon", optional: true
  has_many :children, class_name: "Taxon", foreign_key: "parent_id", dependent: :restrict_with_exception
  belongs_to :species, optional: true
  belongs_to :ebird_taxon, optional: true

  has_many :observations, dependent: :restrict_with_exception
  has_many :images, through: :observations

  scope :category_species, -> {where(category: "species")}
  scope :listable, -> { where.not(species_id: nil) }

  def self.weighted_by_abundance
    obs = Observation.select("taxon_id, COUNT(observations.id) as weight").group(:taxon_id)
    self.joins("LEFT OUTER JOIN (#{obs.to_sql}) obs on id = obs.taxon_id")
  end

  # Parameters

  def to_param
    ebird_code
  end

  def to_label
    [name_sci, name_en].join(" - ")
  end

  def countable?
    species_id.present?
  end

  def is_a_species?
    category == "species"
  end

  # 1. This is mostly used when promoting ebird taxon to taxon (and further to species)
  # 2. But it also can be called separately to create a species after taxon category is
  # manually changed to species (like Motacilla feldegg).
  # 3. It also contains additional logic to fix an existing species relation after taxonomy update,
  # when lump or split occurred:
  #     a. Lump: Species is linked to a nominative subspecies(taxon-issf) that was formerly a species. It should be
  #        relinked to a newly promoted taxon-species (superspecies), and also to its children (who are the
  #        lumped taxa).
  #     b. Split: Species is linked to a slash or spuh taxon that was formerly a (super)species. It should be relinked
  #        to a newly promoted or existing nominative taxon-species (that was formerly a taxon-subspecies)
  def lift_to_species
    if category == "species"
      new_species = species

      ActiveRecord::Base.transaction do

        if new_species.nil?
          new_species = Species.find_by_name_sci(name_sci)
        end

        # Unlink old taxa
        if new_species
          new_species.taxa.where.not(id: self.id).each {|tx| tx.update(species_id: nil)}
        end

        if new_species.nil?
          prev_sp_index_num =
              Species.
                  joins("INNER JOIN taxa on species.id = taxa.species_id").
                  where(taxa: {category: "species"}).
                  where("taxa.index_num < ?", index_num).order("species.index_num DESC").
                  limit(1).pluck("species.index_num").first
          new_sp_index_num = prev_sp_index_num ? prev_sp_index_num + 1 : 1
          new_species = self.build_species(
              index_num: new_sp_index_num
          )
        end

        new_species.update!(
            name_sci: name_sci,
            name_en: name_en,
            order: order,
            family: family.match(/^\w+dae/)[0]
        )

        self.update!(species_id: new_species.id)

        self.children.each {|tx| tx.update(species_id: new_species.id)}

      end
      new_species
    end
  end

end
