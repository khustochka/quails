class RemoveUnusedTaxa < ActiveRecord::Migration
  def change
    # Observed taxa
    observed_taxa = Taxon.where(id: Observation.select(:taxon_id))
    # Species in posts:
    rx = /\{\{(?:([^@#\\^&][^\}]*?)\|)?([^@#\\^&][^\}]*?)(\|en)?\}\}/
    in_posts_codes = Post.all.map { |p| p.text.scan(rx).map(&:second) }.inject(:+).uniq
    in_posts_sps = Species.where("code IN (?) OR name_sci IN (?)", in_posts_codes, in_posts_codes)
  end
end
