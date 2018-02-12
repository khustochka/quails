class AddForeignKeys < ActiveRecord::Migration[5.1]
  def change

    add_foreign_key "cards", "loci", on_delete: :restrict
    add_foreign_key "cards", "posts", on_delete: :nullify
    add_foreign_key "comments", "commenters", on_delete: :restrict
    #add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
    add_foreign_key "comments", "posts", on_delete: :cascade
    add_foreign_key "ebird_submissions", "cards", on_delete: :cascade
    add_foreign_key "ebird_submissions", "ebird_files", on_delete: :cascade
    add_foreign_key "ebird_taxa", "ebird_taxa", column: "parent_id", on_delete: :restrict
    add_foreign_key "local_species", "loci", on_delete: :cascade
    add_foreign_key "local_species", "species", on_delete: :cascade
    add_foreign_key "media_observations", "media", on_delete: :cascade
    add_foreign_key "media_observations", "observations", on_delete: :restrict
    add_foreign_key "media", "media", column: "parent_id", on_delete: :nullify
    add_foreign_key "media", "spots", on_delete: :nullify
    add_foreign_key "observations", "cards", on_delete: :restrict
    add_foreign_key "observations", "loci", column: "patch_id", on_delete: :nullify
    add_foreign_key "observations", "posts", on_delete: :nullify
    add_foreign_key "observations", "taxa", on_delete: :restrict
    add_foreign_key "species_images", "media", column: "image_id", on_delete: :cascade
    add_foreign_key "species_images", "species", on_delete: :cascade
    add_foreign_key "species_splits", "species", column: "superspecies_id", on_delete: :cascade
    add_foreign_key "species_splits", "species", column: "subspecies_id", on_delete: :cascade
    add_foreign_key "spots", "observations", on_delete: :cascade
    add_foreign_key "taxa", "species", on_delete: :nullify
    add_foreign_key "taxa", "taxa", column: "parent_id", on_delete: :restrict
    add_foreign_key "taxa", "ebird_taxa", on_delete: :restrict
  end
end
