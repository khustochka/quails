class EbirdTaxon < ApplicationRecord

  include ActiveRecord::Localized
  localize :name

  acts_as_ordered :index_num

  # validates :order, :presence => true
  # validates :family, :presence => true
  # validates :name_sci, :format => /\A[A-Z][a-z]+ [a-z]+\Z/, :uniqueness => {scope: :book_id}
  # validates :avibase_id, :format => /\A[\dA-F]{16}\Z/, :allow_blank => true
  # validates :species_id, uniqueness: {scope: :book_id}, :allow_blank => true

  # Associations

  belongs_to :parent, class_name: "EbirdTaxon"
  has_many :children, class_name: "EbirdTaxon", foreign_key: "parent_id"
  has_one :taxon

  # Parameters

  # temporarily using ebird code
  def to_param
    ebird_code
  end

  def promote
    return taxon if taxon

    # If parent exists promote it
    promoted_parent = if parent
                        parent.promote
                      else
                        nil
                      end

    # Creating taxon

    attr_hash = attributes.slice("name_sci", "name_en", "ebird_code", "category", "order", "family")
    prev_index_num =
        Taxon.
            joins("INNER JOIN ebird_taxa on ebird_taxa.id = taxa.ebird_taxon_id").
            where("ebird_taxa.index_num < ?", index_num).order("taxa.index_num DESC").
            limit(1).pluck("taxa.index_num").first
    new_index_num = prev_index_num ? prev_index_num + 1 : 1
    attr_hash.merge!({index_num: new_index_num})
    if promoted_parent
      attr_hash.merge!({parent_id: promoted_parent.id, species_id: promoted_parent.species_id})
    end
    new_taxon = self.create_taxon!(attr_hash)
    self.save!

    # Creating species

    if category == "species"
      prev_sp_index_num =
          Species.
              joins("INNER JOIN taxa on species.id = taxa.species_id").
              where(taxa: {category: "species"}).
              where("taxa.index_num < ?", new_taxon.index_num).order("species.index_num DESC").
              limit(1).pluck("species.index_num").first
      new_sp_index_num = prev_sp_index_num ? prev_sp_index_num + 1 : 1
      new_taxon.create_species!(
          name_sci: new_taxon.name_sci,
          name_en: new_taxon.name_en,
          order: new_taxon.order,
          family: new_taxon.family.match(/^\w+dae/)[0],
          index_num: new_sp_index_num
      )
      new_taxon.save!
    end

    # Return the taxon
    new_taxon

  end

end
