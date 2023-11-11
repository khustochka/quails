class AddTaxonConceptId < ActiveRecord::Migration[7.1]
  def change
    add_column :ebird_taxa, :taxon_concept_id, :string
    add_column :taxa, :taxon_concept_id, :string
  end
end
