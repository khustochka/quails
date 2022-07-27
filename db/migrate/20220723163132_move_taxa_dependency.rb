class MoveTaxaDependency < ActiveRecord::Migration[7.0]
  def change
    add_reference :ebird_taxa, :taxon, foreign_key: { on_delete: :nullify }
    ebird_taxa = EbirdTaxon.all.index_by(&:id)
    Taxon.find_each do |taxon|
      ebird_taxa[taxon.ebird_taxon_id].update!(taxon_id: taxon.id) if taxon.ebird_taxon_id
    end
    remove_column :taxa, :ebird_taxon_id
  end
end
