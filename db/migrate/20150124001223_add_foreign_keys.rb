class AddForeignKeys < ActiveRecord::Migration
  def change

      add_foreign_key "cards", "loci", name: "cards_locus_id_fk"
      add_foreign_key "cards", "posts", name: "cards_post_id_fk"
      add_foreign_key "comments", "commenters", name: "comments_commenter_id_fk"
      #add_foreign_key "comments", "comments", column: "parent_id", name: "comments_parent_id_fk"
      add_foreign_key "comments", "posts", name: "comments_post_id_fk"
      add_foreign_key "ebird_submissions", "cards", name: "ebird_submissions_card_id_fk", on_delete: :cascade
      add_foreign_key "ebird_submissions", "ebird_files", name: "ebird_submissions_ebird_file_id_fk", on_delete: :cascade
      add_foreign_key "local_species", "loci", name: "local_species_locus_id_fk"
      add_foreign_key "media_observations", "media", name: "media_observations_media_id_fk"
      add_foreign_key "media_observations", "observations", name: "media_observations_observation_id_fk"
      add_foreign_key "media", "media", column: "parent_id", name: "media_parent_id_fk"
      add_foreign_key "media", "spots", name: "media_spot_id_fk"
      add_foreign_key "observations", "cards", name: "observations_card_id_fk"
      add_foreign_key "observations", "loci", column: "patch_id", name: "observations_patch_id_fk"
      add_foreign_key "observations", "posts", name: "observations_post_id_fk"
      #add_foreign_key "observations", "species", name: "observations_species_id_fk"
      add_foreign_key "species_images", "media", column: "image_id", name: "species_images_image_id_fk", on_delete: :cascade
      add_foreign_key "species_images", "species", name: "species_images_species_id_fk", on_delete: :cascade
      add_foreign_key "spots", "observations", name: "spots_observation_id_fk", on_delete: :cascade
      add_foreign_key "taxa", "books", name: "taxa_book_id_fk"
      add_foreign_key "taxa", "species", name: "taxa_species_id_fk"
  end

  # TODO: get rid of 0 value as NullObject (obs.species_id, comments.parent_id)

end
