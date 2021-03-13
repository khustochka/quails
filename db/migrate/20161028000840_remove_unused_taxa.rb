class RemoveUnusedTaxa < ActiveRecord::Migration[4.2]
  def change
    # Observed taxa
    observed_taxa = Taxon.where(id: Observation.select(:taxon_id)).preload(:species, :parent)
    observed_species = observed_taxa.map(&:species)
    observed_taxa_parents = observed_taxa.map(&:parent)

    # Species in posts:
    rx = /\{\{(?:([^@#\\^&][^\}]*?)\|)?([^@#\\^&][^\}]*?)(\|en)?\}\}/
    in_posts_codes = Post.all.map { |p| p.body.scan(rx).map(&:second) }.inject(:+)&.uniq
    in_posts_sps = Species.where("code IN (?) OR name_sci IN (?)", in_posts_codes, in_posts_codes).preload(:high_level_taxa)
    taxa_in_posts = in_posts_sps.map(&:high_level_taxon)

    # Species in checklists
    local_species = Species.where(id: LocalSpecies.select(:species_id)).preload(:high_level_taxa)
    local_taxa = local_species.map(&:high_level_taxon)

    all_species = [observed_species.compact.map(&:id), in_posts_sps.select(&:id), local_species.select(&:id)].inject(&:+)&.uniq.compact
    all_taxa = [observed_taxa.select(&:id), observed_taxa_parents.compact.map(&:id), taxa_in_posts.map(&:id), local_taxa.map(&:id)].inject(&:+)&.uniq.compact

    Species.where("id NOT IN (?)", all_species).delete_all
    Taxon.where("id NOT IN (?)", all_taxa).delete_all

    # reindex
    Species.order(:index_num).each_with_index { |sp, i| sp.update_column(:index_num, i+1) }
    Taxon.order(:index_num).each_with_index { |tx, i| tx.update_column(:index_num, i+1) }


  end
end
